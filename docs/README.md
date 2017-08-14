# This is a sample that demonstrates how to use vscode to build and debug dotnet core 2.0 console application in docker container. 

Tested environment:
* OS: macOS Sierra 10.12.6
* Docker: 17.07.0-ce-rc1-mac21 (18848)
* dotnet: 2.0.0-preview2-006497
* vscode: Version 1.16.0-insider (1.16.0-insider)
* ms-vscode.csharp: 1.12.0

Known issues (or features?!):
1. We run container in 'runContainer' task, but we start app in this container only when we decided to debug it. So, in order to do that, we have to attach to the running container and provide the name of container in launch.json. By doing that we have to keep in sync the name of the container in two files. That's not that elegant solution, and definitely is a violation of SRP.
2. The other problem that arise from the #1 is that we leave container runnig even when we finished debugging.

For more details read these articles:
* https://github.com/OmniSharp/omnisharp-vscode/wiki/Attaching-to-remote-processes#configuring-launchjson
* http://blog.jonathanchannon.com/2017/06/07/debugging-netcore-docker/
* https://code.visualstudio.com/docs/extensions/example-debuggers