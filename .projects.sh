#!/bin/bash

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

}

# ###
# Funktion soll neues Projekt erstellen
# ###
function __createProject() {
  # Erstelle neuen Ordner im Projekt Verzeichnis

  # Füge den Namen des Projekts der Variable $supportedProjects hinzu

  # Füge den Namen des Projekts der autocomplete Funktion in .oh-my-zsh/completions/_start | _stop zu
}

# ##
# Funktion soll die Referenz zu dem angegebenen Projekt löschen
# ##
function __removeProject() {
  # Lösche das Projekt aus der Variable $supportedProjects

  # Lösche das Projekt aus der autocomplete Funktion von zsh
}

# ##
# Funktion soll das Projekt komplett vom Computer löschen
# ##
function __deleteProject() {

}
