#!/bin/bash

function goto() {
  if [ -z ${1+x} ]; then
    echo "Please provide the name of the project"
    return
  fi

  eval "cd $(__getProjectDir $1)"
}

function __getProjectDir() {
  source "/Users/lucas.reich/Bash-Functions/projects.conf"


    if [ -z ${1+x} ]; then
      echo $project_path
      return

    else
      echo "$project_path/$1"
      return
    fi
}
