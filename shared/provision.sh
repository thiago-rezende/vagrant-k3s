#!/usr/bin/env bash

#   ██░ ██  ▒█████   ██▀███   █    ██   ██████
#  ▓██░ ██▒▒██▒  ██▒▓██ ▒ ██▒ ██  ▓██▒▒██    ▒
#  ▒██▀▀██░▒██░  ██▒▓██ ░▄█ ▒▓██  ▒██░░ ▓██▄
#  ░▓█ ░██ ▒██   ██░▒██▀▀█▄  ▓▓█  ░██░  ▒   ██▒
#  ░▓█▒░██▓░ ████▓▒░░██▓ ▒██▒▒▒█████▓ ▒██████▒▒
#   ▒ ░░▒░▒░ ▒░▒░▒░ ░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ▒ ▒▓▒ ▒ ░
#   ▒ ░▒░ ░  ░ ▒ ▒░   ░▒ ░ ▒░░░▒░ ░ ░ ░ ░▒  ░ ░
#   ░  ░░ ░░ ░ ░ ▒    ░░   ░  ░░░ ░ ░ ░  ░  ░
#   ░  ░  ░    ░ ░     ░        ░           ░
#
# Filename:   provision.sh
# GitHub:     https://github.com/thiago-rezende
# Maintainer: Thiago Rezende <thiago.manoel.rezende@gmail.com>

# script file name
script_name=`basename "$0"`

# logs directory
logs_directory=${PROVISION_LOGS_DIRECTORY:-/opt/shared/logs/$(hostname)}

# verbosity
if [ -z "${PROVISION_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

# ANSI colors
declare -r                               \
        ansi_black='\033[30m'            \
        ansi_black_bold='\033[0;30;1m'   \
        ansi_red='\033[31m'              \
        ansi_red_bold='\033[0;31;1m'     \
        ansi_green='\033[32m'            \
        ansi_green_bold='\033[0;32;1m'   \
        ansi_yellow='\033[33m'           \
        ansi_yellow_bold='\033[0;33;1m'  \
        ansi_blue='\033[34m'             \
        ansi_blue_bold='\033[0;34;1m'    \
        ansi_magenta='\033[35m'          \
        ansi_magenta_bold='\033[0;35;1m' \
        ansi_cyan='\033[36m'             \
        ansi_cyan_bold='\033[0;36;1m'    \
        ansi_white='\033[37m'            \
        ansi_white_bold='\033[0;37;1m'   \
        ansi_reset='\033[0m'
declare -r ansi_grey="$ansi_black_bold"

# usage message
usage() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold usage $ansi_reset>"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold upgrade $ansi_reset | execute a '$ansi_magenta_bold system wide $ansi_reset' '$ansi_green_bold upgrade $ansi_reset'"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold help $ansi_reset    | show this help message"

  exit 0
}

# invalid argument message
invalid_argument() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_red_bold error $ansi_reset> invalid argument $(if [[ $1 ]]; then echo -e \'$ansi_magenta_bold $1 $ansi_reset\'; fi)"
  echo >&3 -e "|> run '$ansi_cyan_bold $script_name $ansi_white_bold help $ansi_reset' to check the available arguments"

  exit 1
}

# failure procedure
failure() {
  local context=$1
  local log_file=$2

  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_red_bold error $ansi_reset> failed on '$ansi_magenta_bold $context $ansi_reset' context"
  echo >&3 -e "|> [$ansi_white_bold log $ansi_reset] check '$ansi_yellow_bold $log_file $ansi_reset' for more information"
  
  exit 1
}

# logs directory
logs_directory() {
  if [ -d $logs_directory ]; then
    return
  fi

  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold logs $ansi_reset> settnig up the '$ansi_cyan_bold logs $ansi_reset' environment"
  echo >&3 -e "|> [$ansi_white_bold mkdir $ansi_reset] creating the '$ansi_yellow_bold $logs_directory $ansi_reset' directory"

  mkdir >&/tmp/${script_name%.*}__logs__mkdir.log -p $logs_directory

  if [ $? -ne 0 ]; then
    failure "logs" "/tmp/${script_name%.*}__logs__mkdir.log"
  fi
}

# system wide upgrade
upgrade() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold upgrade $ansi_reset> executing a '$ansi_magenta_bold system wide $ansi_reset' '$ansi_green_bold upgrade $ansi_reset'"
  echo >&3 -e "|> [$ansi_white_bold apt $ansi_reset] <$ansi_yellow_bold update $ansi_reset> updating the package repositories"

  apt >&$logs_directory/upgrade__apt__update.log update
  
  if [ $? -ne 0 ]; then
    failure "upgrade" "$logs_directory/upgrade__apt__update.log"
  fi

  apt >&$logs_directory/upgrade__apt__upgrade.log upgrade -y
  
  if [ $? -ne 0 ]; then
    failure "upgrade" "$logs_directory/upgrade__apt__upgrade.log"
  fi
}

# argument handler
case $1 in
  upgrade) logs_directory; upgrade;;
  help) usage;;
  *) invalid_argument $1;;
esac