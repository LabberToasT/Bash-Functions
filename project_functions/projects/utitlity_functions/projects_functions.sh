# In dieser Datei stehen funktionen, welche Hilfsmethoden für das projects Command sind

# ###
# Funktion überprüft, ob die angegebene URL zu einem GIT Projekt gehört
#
# Erwartet eine GIT URL
# ###
function __isGitUrl() {
  local gitUrl=$1

  eval "git ls-remote \"$gitUrl\" --exit-code && return 1 | return 0"
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
# Funktion soll ProjektOrdner erstellen und dann das git projekt runterladen
# ##
function __setupProject() {
  local projectName=$1
  local gitUrl=$2

  __addProject $projectName

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
# Funktion fügt Projekt zu der Liste der unterszützen Projekte hinzu
#
# Erwartet den Namen des Projekts als Argument
# ##
function __addToSupportedProjects() {
  eval "echo $1 >> $(__getSupportedProjectsDir)"
}

# ##
# Funktion löscht Projekt aus der Liste der unterstützten Projekte
#
# Erwartet den Namen des Projekts als Argument
# ##
function __removeFromSupportedProjects() {
  eval "sed -i '' \"/$1/d\" $(__getSupportedProjectsDir)"
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
