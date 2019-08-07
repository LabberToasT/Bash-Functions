#!/bin/bash

# Colours in Bash example: https://stackoverflow.com/a/5947802
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

# ##
# Expects string that has to be converted to lowercase
# ##
function __toLower() {
  echo $(basename "$1") |tr '[:upper:]' '[:lower:]'
}

function __clearConsole() {
  printf "\033c"
}

# ##
# This function will change the value of given key in given file
#
# Function expects 3 Arguments
#  1: Key which should be replaced
#  2: Value which should be assigned to the key
#  3: File that contains the key
# ##
function __replaceKeyInFile() {
  local key=$1
  local newValue=$2
  local fileName=$3

  eval "sed -i '' 's;$key=.*;$key=$newValue;' $fileName"
}

# ##
# Funktion erstellt den angegebenen Ornder, falls dieses noch nicht existiert
#
# Ertwartet den Pfad als Argument
# ##
function __createDirIfNotExists() {
  mkdir -p $1
}

# ##
# Looks in the current dir for a GIT repository and extracts the name from the URL
# ##
function __getGitProjectName() {
  echo $(basename -s .git `git config --get remote.origin.url`)
}

# ##
# Funktion um alle Projekte in einer Zeile anzuzeigen
#
# Der Funktion kann ein Projektnamen übergeben werden, sodass sie diesen ignoriert
# ##
function __getSupportedProjectsOneLine() {
  if [ -z ${1+x} ]; then
    excludedProject=""
  else
    excludedProject=$1
  fi

  local projects=();

  cat ~/.custom_commands/.supported_projects | while read project; do
    if [ "$project" != "$excludedProject" ]; then
      projects+=("$project")
    fi
  done

  echo $projects;
}
