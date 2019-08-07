#!/bin/bash


# ##
# Expects Command that should be executed
#
# TODO: Kann ich dem run command auch autotype geben?
# ##
function run() {
  if __isProjectSupported $(__getGitProjectName); then
  else
    echo "Project is not supported by run"
    return
  fi

  if __isRunning; then
  else
    echo "Project is not running."
    return
  fi

  eval $(__buildCommand $*)
}

# ##
# Expects the command which should be called
# ##
function __buildCommand() {
  local command=("docker-compose exec -T" $(__toLower $(__getGitProjectName))"-web-php");
  local command2=("docker-compose exec -T" $(__getWebContainerName2 $(__getGitProjectName)))

  case $1 in
    "behat")
      command=("$command php vendor/bin/behat" $(echo "${@:2}" "--strict --format=progress --colors"))
    ;;
    "unit")
      command=("$command php vendor/bin/phpunit --configuration=phpunit.xml.dist --colors=never" $(echo "${@:2}"))
    ;;
    "fixer")
      command=("$command php vendor/bin/php-cs-fixer fix --config=.php_cs.dist -v --ansi")
    ;;
    *)
      command=($command $*)
    ;;
  esac

  echo $command
}
