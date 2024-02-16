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
# Filename:   certificates.sh
# GitHub:     https://github.com/thiago-rezende
# Maintainer: Thiago Rezende <thiago.manoel.rezende@gmail.com>

# script file name
script_name=`basename "$0"`

# logs directory
logs_directory=${CERTIFICATES_LOGS_DIRECTORY:-/shared/.logs/certificates/$(hostname)}

# certificates directory
certificates_directory=${CERTIFICATES_DIRECTORY:-/shared/.certs}

# verbosity
if [ -z "${CERTIFICATES_QUIET_LOGS:-}" ]; then
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
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold loadbalancers $ansi_reset | setup '$ansi_yellow_bold loadbalancers $ansi_reset' certificates"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold servers $ansi_reset       | setup '$ansi_yellow_bold servers $ansi_reset' certificates"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold workers $ansi_reset       | setup '$ansi_yellow_bold workers $ansi_reset' certificates"
  echo >&3 -e "|> $ansi_cyan_bold $script_name $ansi_white_bold help $ansi_reset          | show this help message"

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

# certificates directory
certificates_directory() {
  if [ -d $certificates_directory ]; then
    return
  fi

  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold certificates $ansi_reset> setting up the '$ansi_cyan_bold certificates $ansi_reset' environment"
  echo >&3 -e "|> [$ansi_white_bold mkdir $ansi_reset] creating the '$ansi_yellow_bold $certificates_directory $ansi_reset' directory"

  mkdir >&/tmp/${script_name%.*}__certificates__mkdir.log -p $certificates_directory

  if [ $? -ne 0 ]; then
    failure "certificates" "/tmp/${script_name%.*}__certificates__mkdir.log"
  fi
}


# setup loadbalancers
loadbalancers() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold loadbalancers $ansi_reset> setup '$ansi_yellow_bold loadbalancers $ansi_reset' certificates"
  echo >&3 -e "|> [$ansi_white_bold openssl $ansi_reset] <$ansi_yellow_bold generate $ansi_reset> generating '$ansi_cyan_bold X.509 $ansi_reset' certificates"

  openssl >&$logs_directory/loadbalancers__openssl__req.log req -x509 -keyout $certificates_directory/loadbalancers.key -out $certificates_directory/loadbalancers.crt -noenc -config /shared/templates/.results/loadbalancers.cnf

  if [ $? -ne 0 ]; then
    failure "loadbalancers" "$logs_directory/loadbalancers__openssl__req.log"
  fi
}

# setup servers
servers() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold servers $ansi_reset> setup '$ansi_yellow_bold servers $ansi_reset' certificates"
  echo >&3 -e "|> [$ansi_white_bold openssl $ansi_reset] <$ansi_yellow_bold generate $ansi_reset> generating '$ansi_cyan_bold X.509 $ansi_reset' certificates"

  openssl >&$logs_directory/servers__openssl__help.log --help

  if [ $? -ne 0 ]; then
    failure "servers" "$logs_directory/servers__openssl__help.log"
  fi
}

# setup workers
workers() {
  echo >&3 -e "[$ansi_green_bold $script_name $ansi_reset] <$ansi_white_bold workers $ansi_reset> setup '$ansi_yellow_bold workers $ansi_reset' certificates"
  echo >&3 -e "|> [$ansi_white_bold openssl $ansi_reset] <$ansi_yellow_bold generate $ansi_reset> generating '$ansi_cyan_bold X.509 $ansi_reset' certificates"

  openssl >&$logs_directory/workers__openssl__help.log --help

  if [ $? -ne 0 ]; then
    failure "workers" "$logs_directory/workers__openssl__help.log"
  fi
}

# argument handler
case $1 in
  loadbalancers) logs_directory; certificates_directory; loadbalancers;;
  servers) logs_directory; certificates_directory; servers;;
  workers) logs_directory; certificates_directory; workers;;
  help) usage;;
  *) invalid_argument $1;;
esac
