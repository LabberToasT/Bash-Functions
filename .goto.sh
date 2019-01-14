#!/bin/bash

function goto() {
  if [ -z ${1+x} ]; then
    echo "Please provide the name of the project"
    return
  fi

  project=$(__toLower $1)

  case $project in
    "nms")
      cd ~/Documents/Projects/NMS
      ;;
    "lms")
      cd ~/Documents/Projects/LMS
      ;;
    "ims")
      cd ~/Documents/Projects/IMS
      ;;
    "ims-2")
      cd ~/Documents/Projects/IMS-2
      ;;
    *)
      echo "Project '$project' is not supported"
      ;;
esac
}
