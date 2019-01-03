#!/bin/bash
supportedProjects=(IMS IMS-2 LMS NMS)

# Place this file in the "~/" Directory.
# After you added the file to the directory add "source ~/.project_functions.sh"
# to the .zshrc file in the same directory.
# Now you should be able to execute the functions.

# ##
# Expects Command that should be executed
# ##
function run() {
  if __isProjectSupported $(__getGitProjectName) && __isGitProject; then
  else
    echo "Project is not supported by run"
    return
  fi

  if __isRunning; then
  else
    echo "Project is not running."
    return
  fi

  eval $(__getCommand $*)
}

# ##
# Expects Project name that has to be started
# ##
function start() {
  if [ -z ${1+x} ]; then
    echo "Please provide the name of the application to start"
    return
  fi

  local project=$1

  if __isProjectSupported $project; then
  else
    echo "Could not start Project '$project'. Resources could not be found!"
    return
  fi

  (cd $(__getProjectDir $project) && __startProject)
}

# ##
# Expects Project name that has to be stopped
# ##
function stop() {

  if [ -z ${1+x} ]; then
    echo "Please provide the name of the application to stop"
    return
  fi

  local project=$1

  if __isProjectSupported $project; then
  else
    echo "Could not stop Project '$project'. Resources could not be found!"
    return
  fi

  (cd $(__getProjectDir $project) && __stopProject)
}

# ##
# Looks in the current dir for running project
# ##
function __isRunning() {
  local containerName=$(__getWebContainerName)

  if [[ `docker ps -q --no-trunc --filter "name=$containerName"` != "" ]]; then
      return 0 # TRUE
    else
      return 1 # FALSE
  fi
}

# ##
# Expects Project name to search for
# ##
function __getProjectDir(){
  echo $(mdfind kind:folder "$1" | grep -E ".*Projects\/$1$")
}

# ##
# Looks in the current dir for a GIT repository and extracts the name from the URL
# ##
function __getGitProjectName() {

  if __isGitProject; then
  else
    echo "Could not find git project in current directory"
    return
  fi

  local projectName=$(basename -s .git `git config --get remote.origin.url`)

  echo $(__toLower $projectName)
}

# ##
# Expects project name to search for
# ##
function __isProjectSupported() {
  for project in "${supportedProjects[@]}"
  do
     :
     if [ $(__toLower $project) = $(__toLower $1) ]; then
       return 0 # TRUE
     fi
  done

  return 1 # FALSE
}

# ##
# Expects the command which should be called
# ##
function __getCommand() {
  local command=("docker-compose exec" $(__getGitProjectName)"-web-php");

  case $1 in
    "behat")
      command=("$command php vendor/bin/behat --strict --format=progress --colors -v")
    ;;
    "unit")
      command=("$command php vendor/bin/phpunit --configuration=phpunit.xml.dist --colors=never --coverage-text")
    ;;
    *)
      command=($command $*)
    ;;
  esac

  echo $command
}

# ##
# Builds kubernetes web pod name
# ##
function __getWebContainerName() {
  local lowerCaseFolderName=$(__toLower $(basename "$PWD"))

  local beginning=$(echo ${lowerCaseFolderName}_${})

  local mid=$(__getGitProjectName $lowerCaseFolderName)

  echo "$beginning$mid-web-php"
}

# ##
# Expects string that has to be converted to lowercase
# ##
function __toLower() {
  echo $(basename "$1") |tr '[:upper:]' '[:lower:]'
}

# ##
# Checks current dir if it contains a git repository
# ##
function __isGitProject() {
  if [ -d .git ]
  then
    return 0 # TRUE
  else
    return 1 # FALSE
  fi
}

function __startProject() {
  docker-compose up -d
}

function __stopProject() {
  docker-compose down
}
