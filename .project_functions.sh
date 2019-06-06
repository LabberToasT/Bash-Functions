#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

# Place this file in the "~/" Directory.
# After you added the file to the directory add "source ~/.project_functions.sh"
# to the .zshrc file in the same directory.
# Now you should be able to execute the functions.

# TODO: Kann ich dem run command auch autotype geben?

# ##
# Expects Command that should be executed
# ##
function run() {
  if __isProjectSupported $(__getGitProjectName); then
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
# User has to be in Project directory or provide the name of the application to start
# ##
function start() {
  local project=$(__getProjectName $1)

  if __isProjectSupported $project; then
  else
    echo "Could not start Project '$project'. Project is not supported"
    return
  fi

  eval "cd $(__getProjectDir $project) && __startProject $project"
}

# ##
# Expects Project name that has to be stopped
# ##
function stop() {
  local project=$(__getProjectName $1)

  if __isProjectSupported $project; then
  else
    echo "Could not stop Project '$project'. Project is not supported!"
    return
  fi

  eval "cd $(__getProjectDir $project) && __stopProject $project"
}

# ##
# Will update the project in the current Directory
# ##
function update() {
  if __isProjectSupported $(__getGitProjectName); then
  else
    echo "Project is not supported by run"
    return
  fi

  if __isRunning; then
  else
    echo "Project is not running. Start it with 'start PROJECT_NAME'"
    return
  fi

  __clearConsole
  # pull latest changes from Repository
  echo -e "${GREEN}Pulling latest changes from remote${NC}"
  git pull
  echo -e "${GREEN}Done${NC}"
  sleep 1

  echo -e "${GREEN}Removing deleted branches${NC}"
  git fetch --prune
  echo -e "${GREEN}Done${NC}"
  sleep 1

  if __projectSupportsMigrations $(__getGitProjectName); then
  else
    # Migrations für das Projekt ausführen, wenn dieses Doctrine Migrations unterstützt
    echo "${GREEN}Running migrations${NC}"
    run bin/console mi:mi
  fi

  __clearConsole
  # Composer install für das Projekt ausführen
  echo "${GREEN}Running composer install${NC}"
  run composer install
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
# Looks in the current dir for a GIT repository and extracts the name from the URL
# ##
function __getGitProjectName() {
  echo $(basename -s .git `git config --get remote.origin.url`)
}

# ##
# Expects project name to search for
# ##
function __isProjectSupported() {
  local lowerCaseProjects=$(__getSupportedProjectsOneLine)

  if [[ $lowerCaseProjects =~ .*$1.* ]]
  then
    return 0 # TRUE
  fi

  return 1 # FALSE
}

# ##
# Expects project name to check for
# ##
function __projectSupportsMigrations() {
  if [ $1 = "IMS" ]; then
    return 0 # FALSE
  else
    return 1 # TRUE
  fi
}

# ##
# Expects the command which should be called
# ##
function __getCommand() {
  local command=("docker-compose exec -T" $(__toLower $(__getGitProjectName))"-web-php");

  case $1 in
    "behat")
      command=("$command php vendor/bin/behat" $(echo "${@:2}" "--strict --format=progress --colors"))
    ;;
    "unit")
      command=("$command php vendor/bin/phpunit --configuration=phpunit.xml.dist --colors=never" $(echo "${@:2}"))
    ;;
    "fixer")
      # command=("git diff --name-only | while read filename; do $command php vendor/bin/php-cs-fixer fix $filename --config=.php_cs.dist -v; done;")
      command=("command php vendor/bin/php-cs-fixer fix --config=.php_cs.dist -v --ansi")
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

  local mid=$(__toLower $(__getGitProjectName) $lowerCaseFolderName)

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
  if [ -d .git ]; then
    return 0 # TRUE
  else
    return 1 # FALSE
  fi
}

function __clearConsole() {
  printf "\033c"
}

# ##
# This function will stop, based on the project name, the given Project
# ##
function __stopProject() {
  project=$1

  case $project in
    [IiLlNn][Mm][Ss]) docker-compose down ;; # If Project is IMS, LMS or NMS
    *)
      echo "Could not stop Project '$project'"
      return 1
  esac
}

# ##
# This function will start, based on the project name, the given Project
# ##
function __startProject() {
  project=$1

  case $project in
    [IiLlNn][Mm][Ss]) docker-compose up -d ;; # If Project is IMS, LMS or NMS
    *)
      echo "Could not start Project '$project'"
      return 1
  esac
}

# ##
# This function will return the name of a Project.
# If this function receives an argument this will be checked with existing Projects.
# If no argument is provided, the function will use the name of the current directory.
# ##
function __getProjectName() {
  if [ -z ${1+x} ]; then
    if ! __isGitProject; then
      echo -e "${RED}Current directory does not contain a project."
      echo -e "Please provide the name of the application to stop or navigate into the project folder.${NC}"
      return
    fi

    echo $(__getGitProjectName)
  else
    echo $1
  fi
}
