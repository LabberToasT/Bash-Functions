#!/bin/bash

function revealSecrets() {
  local filesToReveal=$(__getFilesToReveal)

  arr=($(echo $filesToReveal | tr "\n" "\n"))
  for fileToReveal in "${arr[@]}"
  do
    local pythonCommand="from revealSecrets import revealSecrets; revealSecrets('/Users/lucas.reich/PhpstormProjects/IMS/$fileToReveal')"
    ( cd /Users/lucas.reich/Bash-Functions/project_functions && python3 -c $pythonCommand )
  done
}

function __getFilesToReveal() {
  fileList=`git secret list`

  echo $fileList
}
