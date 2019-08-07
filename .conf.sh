#!/bin/bash

# Command suite welche sich mit dem Konfigurieren der Projects command suite beschäftigt

function projects_config() {
    while getopts ":p:a" opt; do
      case $opt in
        p)
          echo "Setting $OPTARG as project path"
          __saveProjectDir $OPTARG

          return
          ;;
        a)
          echo "TODO $OPTARG"

          return
          ;;
        \?)
          echo "Invalid option: -$OPTARG. Available options are: \n" >&2
          __printSimpleConfigHelp

          return
          ;;
        :)
          echo "Option -$OPTARG requires an argument. Please choose one of the following" >&2
          ;;
      esac
    done
}

# ##
# Funktion um den Pfad des aktuellen Projektverzeichnisses zu bekommen
# ##
function __getProjectDir() {
    source ~/.custom_commands/projects.conf

    echo "$project_path/$1"
}

# ##
# Funktion um den Pfad zur TextDatei der unterstützen Projekte zu bekommen
# ##
function __getSupportedProjectsDir() {
  source ~/.custom_commands/projects.conf

  echo $supported_projects_path
}

# ##
# Funktion erstell ein Configfile in welchem der Pfad zum Projektordner abgelegt ist
#
# Erwartet den Pfad als Argument
# ##
function __saveProjectDir() {
  local newPath=$1
  local keyName=project_path
  local configFile=~/.custom_commands/projects.conf

  __replaceKeyInFile $keyName "\"$newPath\"" $configFile
}

function __printSimpleConfigHelp() {
  echo "  -p <PATH>             Set path as project directory"
  echo "  -a <PROJECT> <ALIAS>  Register alias for Project"
}
