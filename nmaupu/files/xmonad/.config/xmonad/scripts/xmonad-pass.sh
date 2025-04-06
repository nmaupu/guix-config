#!/usr/bin/env sh

DIRNAME=`dirname $0`
. ${DIRNAME}/easyopt/easyopt.sh

usage() {
  cat << EOF
Usage: $0 <options>
 -l   list all passwords
 -c   copy password to the clipboard
 -h   display this help and exit
EOF
}

list() {
  /home/nmaupu/.bin/gopass list --flat
}

copy() {
  PARAM=$1
  /home/nmaupu/.bin/gopass --clip "${PARAM}"
}

easyopt_add "l" 'list && exit 0'
easyopt_add "c:" 'copy "$OPTARG" && exit 0'
easyopt_add "h" 'usage && exit 0'
easyopt_parse_opts "$@"

usage && exit 0
