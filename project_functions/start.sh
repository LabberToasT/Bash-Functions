#!/bin/bash

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
# This function will start, based on the project name, the given Project
# ##
function __startProject() {
  local project=$1

  case $project in
    [IiLlNn][Mm][Ss]) docker-compose up -d ;; # If Project is IMS, LMS or NMS
    contract-service) docker-compose up -d ;; # If Project is contract-service
    *)
      echo "Could not start Project '$project'"
      return 1
  esac
}
