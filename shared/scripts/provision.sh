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
logs_directory=${PROVISION_LOGS_DIRECTORY:-/shared/.logs/provision/$(hostname)}

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
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold dependencies $ansi_reset | setup '$ansi_magenta_bold system wide $ansi_reset' dependencies"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold services $ansi_reset     | start system '$ansi_yellow_bold services $ansi_reset'"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold configs $ansi_reset      | setup '$ansi_yellow_bold config $ansi_reset' files"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold swapoff $ansi_reset      | disable '$ansi_yellow_bold swap $ansi_reset' files '$ansi_magenta_bold system wide $ansi_reset'"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold upgrade $ansi_reset      | execute a '$ansi_magenta_bold system wide $ansi_reset' upgrade"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold hosts $ansi_reset        | update the '$ansi_yellow_bold hosts $ansi_reset' file"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold help $ansi_reset         | show this help message"

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

  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold logs $ansi_reset> setting up the '$ansi_cyan_bold logs $ansi_reset' environment"
  echo >&3 -e "|> [$ansi_white_bold mkdir $ansi_reset] creating the '$ansi_yellow_bold $logs_directory $ansi_reset' directory"

  mkdir >&/tmp/${script_name%.*}__logs__mkdir.log -p $logs_directory

  if [ $? -ne 0 ]; then
    failure "logs" "/tmp/${script_name%.*}__logs__mkdir.log"
  fi
}

# system wide upgrade
upgrade() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold upgrade $ansi_reset> executing a '$ansi_magenta_bold system wide $ansi_reset' upgrade"
  echo >&3 -e "|> [$ansi_white_bold apk $ansi_reset] <$ansi_yellow_bold update $ansi_reset> updating the package repositories"

  apk >&$logs_directory/upgrade__apk__update.log update

  if [ $? -ne 0 ]; then
    failure "upgrade" "$logs_directory/upgrade__apk__update.log"
  fi

  echo >&3 -e "|> [$ansi_white_bold apk $ansi_reset] <$ansi_yellow_bold upgrade $ansi_reset> upgrading the installed packages"

  apk >&$logs_directory/upgrade__apk__upgrade.log upgrade

  if [ $? -ne 0 ]; then
    failure "upgrade" "$logs_directory/upgrade__apk__upgrade.log"
  fi
}

# setup dependencies
dependencies() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold dependencies $ansi_reset> setup '$ansi_magenta_bold system wide $ansi_reset' dependencies"
  echo >&3 -e "|> [$ansi_white_bold apk $ansi_reset] <$ansi_yellow_bold add $ansi_reset> installing '$ansi_magenta_bold vim $ansi_reset' package"

  apk >&$logs_directory/dependencies__apk__add__vim.log add vim

  if [ $? -ne 0 ]; then
    failure "dependencies" "$logs_directory/dependencies__apk__add__vim.log"
  fi

  if [[ $HOSTNAME == *"loadbalancer"* ]]; then
    echo >&3 -e "|> [$ansi_white_bold apk $ansi_reset] <$ansi_yellow_bold add $ansi_reset> installing '$ansi_magenta_bold nginx $ansi_reset' package"

    apk >&$logs_directory/dependencies__apk__add__nginx.log add nginx

    if [ $? -ne 0 ]; then
      failure "dependencies" "$logs_directory/dependencies__apk__add__nginx.log"
    fi
  fi
}

# setup /etc/hosts
hosts() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold hosts $ansi_reset> setting up the '$ansi_yellow_bold hosts $ansi_reset' file"
  echo >&3 -e "|> [$ansi_white_bold copy $ansi_reset] '$ansi_magenta_bold /shared/templates/.results/hosts $ansi_reset' -> '$ansi_yellow_bold /etc/hosts $ansi_reset'"

  cp >&$logs_directory/hosts__copy.log /shared/templates/.results/hosts /etc/hosts

  if [ $? -ne 0 ]; then
    failure "hosts" "$logs_directory/hosts__copy.log"
  fi
}

# setup config files
configs() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold configs $ansi_reset> setting up the '$ansi_yellow_bold config $ansi_reset' files"
  echo >&3 -e "|> [$ansi_white_bold copy $ansi_reset] '$ansi_magenta_bold /shared/configs/.vimrc $ansi_reset' -> '$ansi_yellow_bold /home/vagrant/.vimrc $ansi_reset'"

  cp >&$logs_directory/configs__copy__vimrc.log /shared/configs/.vimrc /home/vagrant/.vimrc

  if [ $? -ne 0 ]; then
    failure "configs" "$logs_directory/configs__copy__vimrc.log"
  fi

  if [[ $HOSTNAME == *"loadbalancer"* ]]; then
    echo >&3 -e "|> [$ansi_white_bold copy $ansi_reset] '$ansi_magenta_bold /shared/templates/.results/nginx.conf $ansi_reset' -> '$ansi_yellow_bold /etc/nginx/nginx.conf $ansi_reset'"

    cp >&$logs_directory/configs__copy__nginx_conf.log /shared/templates/.results/nginx.conf /etc/nginx/nginx.conf

    if [ $? -ne 0 ]; then
      failure "configs" "$logs_directory/configs__copy__nginx_conf.log"
    fi
  fi
}

# setup config files
swap() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold swap $ansi_reset> disabling '$ansi_yellow_bold swap $ansi_reset' files '$ansi_magenta_bold system wide $ansi_reset'"
  echo >&3 -e "|> [$ansi_white_bold swapoff $ansi_reset] disabling '$ansi_yellow_bold swap $ansi_reset' using '$ansi_cyan_bold swapoff $ansi_reset'"

  swapoff >&$logs_directory/swap__swapoff.log -a

  if [ $? -ne 0 ]; then
    failure "swapoff" "$logs_directory/swap__swapoff.log"
  fi

  echo >&3 -e "|> [$ansi_white_bold sed $ansi_reset] removing '$ansi_yellow_bold swap $ansi_reset' entries from '$ansi_yellow_bold /etc/fstab $ansi_reset'"

  sed >&$logs_directory/swap__sed__fstab.log -i '/swap/d' /etc/fstab

  if [ $? -ne 0 ]; then
    failure "swapoff" "$logs_directory/swap__sed__fstab.log"
  fi
}

# startup services
services() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold services $ansi_reset> starting up the system '$ansi_yellow_bold services $ansi_reset'"

  if [[ $HOSTNAME == *"loadbalancer"* ]]; then
    echo >&3 -e "|> [$ansi_white_bold rc-service $ansi_reset] starting '$ansi_yellow_bold nginx $ansi_reset' service"

    rc-service >&$logs_directory/services__rc_service__nginx__start.log --ifnotstarted nginx start

    if [ $? -ne 0 ]; then
      failure "services" "$logs_directory/services__rc_service__nginx__start.log"
    fi

    echo >&3 -e "|> [$ansi_white_bold rc-service $ansi_reset] reloading '$ansi_yellow_bold nginx $ansi_reset' service"

    rc-service >&$logs_directory/services__rc_service__nginx__reload.log nginx reload

    if [ $? -ne 0 ]; then
      failure "services" "$logs_directory/services__rc_service__nginx__reload.log"
    fi
  fi
}

# argument handler
case $1 in
  dependencies) logs_directory; dependencies;;
  services) logs_directory; services;;
  configs) logs_directory; configs;;
  swapoff) logs_directory; swap;;
  upgrade) logs_directory; upgrade;;
  hosts) logs_directory; hosts;;
  help) usage;;
  *) invalid_argument $1;;
esac
