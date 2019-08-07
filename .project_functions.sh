#!/bin/bash

# Place this file in the "~/" Directory.
# After you added the file to the directory add "source ~/.project_functions.sh"
# to the .zshrc file in the same directory.
# Now you should be able to execute the functions.

# ##
# Looks in the current dir for running project
# ##
function __isRunning() {
  local searchString=($(__toLower $(__getGitProjectName))".*web-php")

  if docker ps --format "{{.Names}}" | grep -q -E $searchString; then
    return 0 # TRUE
  else
    return 1 # FALSE
  fi
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
# Builds kubernetes web pod name based on current directory
# ##
function __getWebContainerName() {
  # Hiermit kann man den Namen aus den laufenden Docker container extrahieren: docker ps --format "{{.Names}}" | grep -E 'contract-service.*web-php'

  local lowerCaseFolderName=$(__toLower $(basename "$PWD"))

  local beginning=$(echo ${lowerCaseFolderName}_${})

  local mid=$(__toLower $(__getGitProjectName) $lowerCaseFolderName)

  echo "$beginning$mid-web-php"
}

# ##
# Function expects project name
# ##
function __getWebContainerName2() {
  local projectName=$(__toLower $1)

  command="docker ps --format \"{{.Names}}\" | grep -E '$projectName.*web-php'"

  echo $(eval $command)
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
