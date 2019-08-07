#!/bin/bash

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
# This function will stop, based on the project name, the given Project
# ##
function __stopProject() {
  local project=$1

  case $project in
    [IiLlNn][Mm][Ss]) docker-compose down ;; # If Project is IMS, LMS or NMS
    contract-service) docker-compose down ;; # If Project is contract-service
    *)
      echo "Could not stop Project '$project'"
      return 1
  esac
}
