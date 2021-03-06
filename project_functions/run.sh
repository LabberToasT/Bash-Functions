#!/bin/bash


# ##
# Expects Command that should be executed
#
# TODO: Kann ich dem run command auch autotype geben?
# TODO: Run fixer sollte nur die Files angucken die auch wirklich geändert wurden. Falls man jedoch alle Fixen will kann man das mit dem Command run fixer -a machen.
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

  case $1 in
    "behat")
      command=("$command vendor/bin/behat " $(echo "${@:2}" "--strict --format=progress --colors -v"))
    ;;
    "unit")
      command=("$command vendor/bin/phpunit --colors=never --coverage-text" $(echo "${@:2}"))
    ;;
    "fixer")
      command=("$command php-cs-fixer.phar fix --config=.php_cs.dist")
      # TODO: Ich möchte dem command die Option -f geben.
      # wählt man diese Option kann man den Namen einer Datei angeben, die gefixt werden soll
      # Dann sucht das Command automatisch den Pfad zu der Datei und fixt diese
      # Bash command um den Pfad zu einer Datei zu bekommen: find . -name 'DATEINAME' -type f
    ;;
    *)
      command=($command $*)
    ;;
  esac

  echo $command
}
