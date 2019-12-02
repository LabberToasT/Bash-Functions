#!/bin/bash

# ##
# Will update the project in the current Directory
# ##
function update() {
  if __isProjectSupported $(__getGitProjectName); then
  else
    echo "Project is not supported by run"
    return
  fi

  if __isRunning; then
  else
    echo "Project is not running. Start it with 'start PROJECT_NAME'"
    return
  fi

  # TODO: Hier sollte ich auch noch composer dump aufrufen

  __clearConsole
  # pull latest changes from Repository
  echo -e "${GREEN}Pulling latest changes from remote${NC}"
  git pull
  echo -e "${GREEN}Done${NC}"
  sleep 1

  echo -e "${GREEN}Removing deleted branches${NC}"
  git fetch --prune
  echo -e "${GREEN}Done${NC}"
  sleep 1

  if __projectSupportsMigrations $(__getGitProjectName); then
  else
    # Migrations für das Projekt ausführen, wenn dieses Doctrine Migrations unterstützt
    echo "${GREEN}Running migrations${NC}"
    run bin/console mi:mi
  fi

  __clearConsole
  # Composer install für das Projekt ausführen
  echo "${GREEN}Running composer install${NC}"
  run composer install
}
