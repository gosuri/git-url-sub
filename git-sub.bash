#!/usr/bin/env bash
#
# Copyright 2011 Greg Osuri <gosuri@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# enable debug mode
if [ "$DEBUG" = "yes" ]
then
	set -x
fi

export GITSUB_DIR=$(dirname "$0")

SUBCOMMAND_LIST=( url )
WORKING_DIR=$(PWD)

usage() {
  cat << EOF
usage: git sub <subcommand>

Available subcommands are:

   url       Recursively substitute remote URLs
             for multiple repositories

Try 'git sub <subcommand> help' for details.
EOF
}

log() {
  if [[ ! $SILENT ]]; then
    echo $1
  fi
}

main() {
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi

  SUBCOMMAND="$1"; shift

  case "${SUBCOMMAND_LIST[@]}" in
    "$SUBCOMMAND") cmd_$SUBCOMMAND "$@" ;;
                *) usage; exit 1 ;;
  esac
}


cmd_url_usage() {
  cat << EOF
usage: git sub url [hSD] <old_url> <new_url>

Will dry run by default, run with -C option to commit changes

OPTIONS:
  -h  Shows this message
  -C	Commit changes
  -S  Silently executes
	
EOF
}

cmd_url() {
  # parse options
  while getopts h:s OPTION
  do
    case $OPTION in
      h)
        cmd_url_usage
        exit 1
        ;;
      S)
        SILENT_FLAG=true
        ;;
      C)
        COMMIT=true
        ;;
      ?)
        shift
    esac
  done

  # check to see if we have both urls
  if [ $# -lt 2 ]
  then
    cmd_url_usage
    exit 1
  fi

  local SOURCE=$1
  local TARGET=$2

  for dir in $(echo $(find . -type dir | grep -v .git) | tr " " "\n")
  do
    for git_dir in $(echo $(ls -A $dir) | tr " " "\n")
    do
      if [[ ${git_dir} == ".git" ]]; then
        cd $dir
        local git_remote_info=($(git remote -v))
        local index=0

        if [[ $(git remote -v | grep -c $SOURCE) > 0  ]]; then
          for branch_info in ${git_remote_info[@]}
          do
            if [[ "$branch_info" = "(fetch)" ]] || [[ "$branch_info" = "(push)" ]]
            then
              local mode=$branch_info
              local url=${git_remote_info[$index-1]}
              local branch=${git_remote_info[$index-2]}
              if [[ $COMMIT ]]; then
                git remote set-url $branch $TARGET
              fi
              log "$dir $url $branch $mode"
           fi
          ((index++))
          done
        fi
      fi
    done
  cd $WORKING_DIR
  done
}

main "$@"
