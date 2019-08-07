#!/bin/bash

# TODO: Config File mit dem Projektverzeichniss erstellen, was der User zu beginn einstellen muss (Wie git user.email/ user.name)

# ##
# Wenn der Funktion kein Argument übergeben wird, dann werden alle Unterstützte Projekte angezeit ($supportedProjects)
#
# Wird der Funktion das Argument -a oder --add und dazu noch ein String übergeben, dann soll ein neues Projekt mit __createProject() angelegt werden
#
# Wird der Funktion das Argument -c oder --create und dazu noch eine GIT URL übergeben, dann soll ein neues Projekt erstellt werden das aus dem angegebenen GIT repository kommt
#
# Wird der Funktion das Argument -d oder --delete und dazu noch ein String übergeben, dann soll das angebene Projekt mit __deleteProject() gelöscht werden
#
# Wird der Funktion das Argument -r oder --remove und dazu noch ein String übergeben, dann soll das angegebene Projekt mit __removeProject() von der Liste der unterstützen Projekte entfernt werden
# ##
function projects() {
  while getopts ":a:c:r:d:h" opt; do
    case $opt in
      a)
        echo "Adding Project $OPTARG"
        __addProject $OPTARG

        return
        ;;
      c)
        echo "Creating Project from GIT URL: $OPTARG"
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
# Funktion erstellt ein neues Projekt, welches manuell vom User erstellt wurde.
# Oder, falls ein bestehendes Projekt ausgesucht wurde, fügt sie dieses der CommandSuite hinzu.
#
#  TODO: Sollte ich hier auch ein GIT Repository mit git init erstellen?
#
# Erwartet den Namen des Projekts als Argument
# ###
function __addProject() {
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
# Funktion erstellt anhand einer GIT Url ein neues Projekt im Projects Verzeichnis
#
# Erwartet eine Url, welche zu einem GIT Repository zeigt.
# ##
function __createProject() {
    if [ -z ${1+x} ]; then
      echo "${RED}Please provide the Project GIT Url${NC}"
      return
    fi
    local gitUrl=$1

    if ! __isGitUrl $gitUrl; then
      echo "${RED}'$1' is not a GIT Url. Aborting script${NC}"
      return
    fi

    # Go to Projects directory
    eval "cd $(__getProjectDir)"

    # Clone git project
    git clone -q $gitUrl

    # Get Name of new created Projectfolder
    local projectName="$(basename "$1" .git)"

    # Add project to projects command suite
    __addProject $projectName
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

function __printSimpleHelp() {
  echo "  -a <ARGUMENT> for Add"
  echo "  -c <ARGUMENT> for Create"
  echo "  -r <ARGUMENT> for Remove"
  echo "  -d <ARGUMENT> for Delete"
  echo "  -h for Help"
}

function __printExtendedHelp() {

  echo "  a <PROJECT NAME>: CREATE NEW Project with given name and add project name to Projects command suite"
  echo "  c <GIT URL>:      CREATE NEW Project from given GIT URl and add project name to Projects command suite"
  echo "  r <PROJECT NAME>: REMOVE given Project from Projects command suite"
  echo "  d <PROJECT NAME>: REMOVE given Project from Projects command suite and DELETE Project folder from Projects directory"
  echo "  h: Print this help message"
}
