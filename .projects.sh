#!/bin/bash
# Colours in Bash example: https://stackoverflow.com/a/5947802
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

# TODO: Config File mit dem Projectverzeichniss erstellen, was der User zu beginn einstellen muss (Wie git user.email/ user.name)

# ##
# Wenn der Funktion kein Argument übergeben wird, dann werden alle Unterstützte Projekte angezeit ($supportedProjects)
#
# Wird der Funktion das Argument -a oder --add und dazu noch ein String übergeben, dann soll ein neues Projekt mit __createProject() angelegt werden
#
# Wird der Funktion das Argument -d oder --delete und dazu noch ein String übergeben, dann soll das angebene Projekt mit __deleteProject() gelöscht werden
#
# Wird der Funktion das Argument -r oder --remove und dazu noch ein String übergeben, dann soll das angegebene Projekt mit __removeProject() von der Liste der unterstützen Projekte entfernt werden
# ##
function projects() {
  while getopts ":a:r:d:h" opt; do
    case $opt in
      a)
        echo "Creating Project $OPTARG"
        __createProject $OPTARG

        return
        ;;
      r)
        echo "Removing Project $OPTARG"
        __removeProject $OPTARG

        return
        ;;
      d)
        echo "Deleting Project $OPTARG"
        __deleteProject $OPTARG

        return
        ;;
      h)
        echo ""
        __printExtendedHelp

        return
        ;;
      \?)
        echo "Invalid option: -$OPTARG. Available options are: \n" >&2
        __printSimpleHelp

        return
        ;;
      :)
        echo "Option -$OPTARG requires an argument. Please choose one of the following" >&2
        ;;
    esac
  done

  echo "Available projects are: $(__getSupportedProjectsOneLine)"
}

# ###
# Funktion erstellt ein neues Projekt
#
# Erwartet den Namen des Projekts als Argument
# ###
function __createProject() {
  if [ -z ${1+x} ]; then
    echo "Please provide the name of the application to start"
    return
  fi
  local projectName=$1

  # Check if Project is already supported
  if __isProjectSupported $projectName; then
    echo "Project is already added to supported Projects."
    echo "Supported projects are: $(__getSupportedProjectsOneLine)"

    echo "Aborting execution."
    return
  fi

  # Check if project Folder exists
  if __projectFolderNotExists $projectName; then
    __createProjectFolder $projectName
  else
    echo "Project '$projectName' already exists. Do you want to add this Project to the supported ones? (y/n)"
    read response

    if [ "$response" = "n" ]; then
      return
    fi
  fi

  __addToSupportedProjects $projectName
  __addProjectToAutocomplete $projectName
  goto $projectName
}

# ##
# Funktion überprüft ob ein Projekt im Projektverzeichnis nicht existiert
#
# Erwartet den Namen des Projekts als Argument
# ##
function __projectFolderNotExists() {
  eval "[ -d $(__getProjectDir)$1 ] && return 1 || return 0"
}

# ##
# Funktion soll die Referenz zu dem angegebenen Projekt löschen
# ##
function __removeProject() {
  local projectName=$1

  # Lösche das Projekt aus der Variable $supportedProjects
  __removeProjectFromAutocomplete $projectName

  # Lösche das Projekt aus der autocomplete Funktion von zsh
  __removeFromSupportedProjects $projectName
}

# ##
# Funktion soll das Projekt komplett vom Computer löschen
# ##
function __deleteProject() {
  projectName=$1
  projectDir=("$(__getProjectDir)$projectName")

  echo -e "You are about to delete the project ${RED}$projectName${NC} from your System."
  echo -e "All files in folder ${RED}$projectDir${NC} will be deleted."
  echo "Are you sure you want to continue? (y/n)"
  read response

  if [ "$response" = "y" ]; then
    eval "rm -rf $projectDir"
    echo "Project has been deleted!"
  else
    echo "Aborting"
  fi
}

# ##
# Funktion soll ProjektOrdner erstellen und dann das git projekt runterladen
# ##
function __setupProject() {
  local projectName=$1
  local gitUrl=$2

  __createProject $projectName

  __downloadProject $gitUrl
}

# ##
# Funktion um ein Projekt zu den autocomplete Funktionen der Projects suite hinzuzufügen
#
# Erwartet den Namen des Projekts als Argument
# ##
function __addProjectToAutocomplete() {
  local autocompleteCommand="_arguments \"1: :($(__getSupportedProjectsOneLine) $1)\""

  local filesToWrite=('_goto' '_start' '_stop')
  for file in "${filesToWrite[@]}"
  do
    sed -i '' "2s/.*/$autocompleteCommand/" ~/.oh-my-zsh/completions/$file
  done
}

# ##
# Funktion um ein Projekt aus den autocomplete Funktion der Projects suite zu entfernen
#
# Erwartet den Namen des Projekts als Argument
# ##
function __removeProjectFromAutocomplete() {
    local autocompleteCommand="_arguments \"1: :($(__getSupportedProjectsOneLine $1))\""

    local filesToWrite=('_goto' '_start' '_stop')
    for file in "${filesToWrite[@]}"
    do
      sed -i '' "2s/.*/$autocompleteCommand/" ~/.oh-my-zsh/completions/$file
    done
}

# ##
# Funktion um einen Ordner im Projektverzeichniss anzulegen
#
# Erwartet den Namen des Projekts als Argument
# ##
function __createProjectFolder() {
  eval "mkdir $(__getProjectDir)$1"
}

# ##
# Funktion um den Pfad zur TextDatei der unterstützen Projekte zu bekommen
# ##
function __getSupportedProjectsFileLoc() {
  echo "~/.supported_projects"
}

# ##
# Funktion fügt Projekt zu der Liste der unterszützen Projekte hinzu
#
# Erwartet den Namen des Projekts als Argument
# ##
function __addToSupportedProjects() {
  eval "echo $1 >> $(__getSupportedProjectsFileLoc)"
}

# ##
# Funktion löscht Projekt aus der Liste der unterstützten Projekte
#
# Erwartet den Namen des Projekts als Argument
# ##
function __removeFromSupportedProjects() {
  eval "sed -i '' \"/$1/d\" $(__getSupportedProjectsFileLoc)"
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

  cat ~/.supported_projects | while read project; do
    if [ "$project" != "$excludedProject" ]; then
      projects+=("$project")
    fi
  done

  echo $projects;
}

function __printSimpleHelp() {
  echo "  -a <ARGUMENT> for Add"
  echo "  -r <ARGUMENT> for Remove"
  echo "  -d <ARGUMENT> for Delete"
  echo "  -h for Help"
}

function __printExtendedHelp() {

  echo "  a <PROJECT NAME>: CREATE NEW Project with given name and add project name to Projects command suite"
  echo "  r <PROJECT NAME>: REMOVE given Project from Projects command suite"
  echo "  d <PROJECT NAME>: REMOVE given Project from Projects command suite and DELETE Project folder from Projects directory"
  echo "  h: Print this help message"
}
