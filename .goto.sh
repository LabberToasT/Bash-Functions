#!/bin/bash

function goto() {
  if [ -z ${1+x} ]; then
    echo "Please provide the name of the project"
    return
  fi

  project=$1

  cd ~/Documents/Projects/$project
}
