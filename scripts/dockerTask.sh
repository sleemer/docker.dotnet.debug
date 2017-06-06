imageName="docker.dotnet.debug"
containerName="${imageName}_1"
workdir="src"

# Builds the Docker image.
buildImage () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="debug"
  fi

  dockerFileName="Dockerfile"
  if [[ $ENVIRONMENT != "release" ]]; then
    dockerFileName="Dockerfile.$ENVIRONMENT"
  fi

  if [[ ! -f "$workdir/$dockerFileName" ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$dockerFileName' does not exist."
  else
    echo "Building the image $imageName ($ENVIRONMENT)."
    docker build -t $imageName -f "$workdir/$dockerFileName" $workdir
  fi
}

runContainer () {
    echo "Running a new container $containerName"
    if [[ -z $(docker images -q $imageName) ]]; then
        echo "Couldn not find an image named $imageName"
    else
        containerId=$(docker ps -f "name=$containerName" -q -n=1)
        if [[ ! -z $containerId ]]; then
            docker stop $containerId
            docker rm $containerId
        fi
        docker run -d --name $containerName $imageName
    fi
}

# Shows the usage for the script.
showUsage () {
  echo "Usage: dockerTask.sh [COMMAND] (ENVIRONMENT)"
  echo "    Runs build or compose using specific environment (if not provided, debug environment is used)"
  echo ""
  echo "Commands:"
  echo "    build: Builds a Docker image ('$imageName')."
  echo "    compose: Runs docker-compose."
  echo "    clean: Removes the image '$imageName' and kills all containers based on that image."
  echo "    composeForDebug: Builds the image and runs docker-compose."
  echo "    startDebugging: Finds the running container and starts the debugger inside of it."
  echo ""
  echo "Environments:"
  echo "    debug: Uses debug environment."
  echo "    release: Uses release environment."
  echo ""
  echo "Example:"
  echo "    ./dockerTask.sh build debug"
  echo ""
  echo "    This will:"
  echo "        Build a Docker image named $imageName using debug environment."
}

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
    "buildForDebug")
            ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
            export REMOTE_DEBUGGING=1
            buildImage
            runContainer
            ;;
    *)
            showUsage
            ;;
  esac
fi