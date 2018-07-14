# This is a sample that demonstrates how to use vscode to build and debug dotnet core 2.0 console application in docker container. 

## Our goal
What we're going to achieve is to be able to build our dotnet core application or library inside a Docker container, so we don't need to install an appropriate sdk on our host machine. After we successfully build an image with the app, we need to spin up a new container and attach debugger to our app inside this container.

## Step-by-step guidline
1. First of all we need to create a docker file that will describe how we are going to build a Docker image with our application.
```dockerfile
FROM microsoft/dotnet:2.1-sdk
ENV NUGET_XMLDOC_MODE skip
WORKDIR /vsdbg

# Installing vsdbg debbuger into our container 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

# Copying source files into container and publish it
RUN mkdir /app
WORKDIR /app

COPY App.csproj /app
RUN dotnet restore

COPY . /app
RUN dotnet publish -c Debug -o out

# Kick off a container just to wait debugger to attach and run the app
ENTRYPOINT ["/bin/bash", "-c", "sleep infinity"]
```
2. Then we create a script file dockerTask.sh that will contain utility task buildForDebug.
This task is responsible for:
    - stopping and removing old container(s)
    - building a new image
    - running a new container 

3. Add task configuration to tasks.json
```json
{
    "taskName": "buildForDebug",
    "suppressTaskName": true,
    "args": [
        "-c",
        "./scripts/dockerTask.sh buildForDebug"
    ],
    "isBuildCommand": false,
    "showOutput": "always"
}
```
4. And the last step is to create the launch configuration in launch.json, that will use task created on the previous step as a preLaunchTask.
```json
{
    "name": ".NET Core Docker Launch (console)",
    "type": "coreclr",
    "request": "launch",                    # we are going to run a new instance of our application
    "preLaunchTask": "buildForDebug",       # name of the task that will build and run a container
    "program": "/app/out/App.dll",          # path to program to run inside a container
    "cwd": "/app/out",                      # working directory inside a container
    "sourceFileMap": {
        "/app": "${workspaceRoot}/src"      # mapping of source code inside a container to the source code on a host machine
    },
    "pipeTransport": {
        "pipeProgram": "docker",            # use Docker as a pipe program
        "pipeCwd": "${workspaceRoot}",
        "pipeArgs": [
            "exec -i docker.dotnet.debug_1" # attach to container and execute command of running app with attached debbuger
        ],
        "quoteArgs": false,
        "debuggerPath": "/vsdbg/vsdbg"      # path to installed debugger inside a container
    }
}
```
And that's basically it. For more details and the full example see the code in the repo.

Tested environment:
* OS: macOS High Sierra 10.13.6
* Docker: 18.05.0-ce-mac67 (25042)
* dotnet: 2.1
* vscode: Version 1.26.0-insider
* ms-vscode.csharp: 1.15.2

Known issues (or features?!):
1. We run container in 'runContainer' task, but we start app in this container only when we decided to debug it. So, in order to do that, we have to attach to the running container and provide the name of container in launch.json. By doing that we have to keep in sync the name of the container in two files. That's not that elegant solution, and definitely is a violation of SRP.
2. The other problem that arise from the #1 is that we leave container running even when we finished debugging.

For more details read these articles:
* https://github.com/OmniSharp/omnisharp-vscode/wiki/Attaching-to-remote-processes#configuring-launchjson
* http://blog.jonathanchannon.com/2017/06/07/debugging-netcore-docker/
* https://code.visualstudio.com/docs/extensions/example-debuggers