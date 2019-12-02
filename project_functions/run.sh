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
      command=("$command vendor/bin/behat " $(echo "${@:2}" "--strict --format=progress --colors -v"))
    ;;
    "unit")
      command=("$command vendor/bin/phpunit --colors=never --coverage-text" $(echo "${@:2}"))
    ;;
    "fixer")
      command=("$command php-cs-fixer.phar fix --config=.php_cs.dist")
    ;;
    *)
      command=($command $*)
    ;;
  esac

  echo $command
}
