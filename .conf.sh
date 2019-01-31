#!/bin/bash

#Command suite welche sich mit dem Konfigurieren der Projects command suite beschäftigt

# ##
# Funktion um den Pfad des aktuellen Projektverzeichnisses zu bekommen
# ##
function __getProjectDir() {
  echo "~/Documents/Projects/"
}

# ##
# Funktion erstell ein Configfile in welchem der Pfad zum Projektordner abgelegt ist
#
# Erwartet den Pfad als Argument
# ##
function __setProjectDir() {
  local givenPath="~/Documents"
  local projectsFolderName="Projects"
  eval "[ -d $(__getProjectDir)$1 ] && return 1 || return 0"
  # check if folder exists
  # -> Y: tell user about it and ask to override
  # -> N: Create folder at given position
}
