#!/usr/bin/env sh
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

puts() {
  if ! [[ $SILENT_FLAG ]]; then
    echo "$1"
  fi
}

usage() {
  cat << EOF
usage: git sub <subcommand>

Available subcommands are:

   url       Recursively substitute remote URLs
             for multiple repositories

Try 'git sub <subcommand> help' for details.
EOF
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
usage: git sub url [cs] <old_url> <new_url>

NOTE: will not commit changes by default, run with -c option to commit changes

OPTIONS:
  -h  Shows this message
  -c  Commit changes
  -s  Silently executes
	
EOF
}

cmd_url() {
  # parse options
  while getopts hsc OPTION
  do
    case $OPTION in
      h)
        cmd_url_usage
        exit 1
        ;;
      c)
        COMMIT=true
        ;;
      s)
        SILENT_FLAG=true
        ;;
      ?)
        cmd_url_usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

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
          local changes_flag=true
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
              puts "$dir $url $branch $mode"
            fi
            ((index++))
          done
        fi
      fi
    done
  cd $WORKING_DIR
  done
  if [[ $changes_flag ]]; then
    puts ""
    if [[ $COMMIT ]]; then
      puts "Changes have been made to the above urls"
    else
      puts "NOTE: No changes have been made. Please run with -c flag to commit changes"
      puts "git sub url -c $SOURCE $TARGET"
    fi
  fi
}

main "$@"
