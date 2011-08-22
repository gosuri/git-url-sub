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
usage: git sub url [hS] <old_url> <new_url>

OPTIONS:
  -h  Shows this message
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
      local prev_url=
      local prev_branch=
      if [[ ${git_dir} == ".git" ]]; then
        cd $dir
        local git_remote=($(git remote -v))
        local index=0
        if [[ $(git remote -v | grep -c $SOURCE) > 0  ]]; then
          for branch_info in ${git_remote[@]}
          do
            if [[ "$branch_info" = "(fetch)" ]] || [[ "$branch_info" = "(push)" ]]
            then
              local branch=${git_remote[$index-2]}
              local url=${git_remote[$index-1]}

              if [[ "$url" != "$prev_url" ]] && [[ "$branch_info" != "$prev_branch" ]]
              then
                echo -n "replace ($url -> $TARGET) for "$branch" under $dir?(Yn): "
                read confirm
                if [[ "$confirm" == "Y" ]]; then
                  git remote set-url $branch $TARGET
                  echo "remote url for $branch is now $TARGET"
                else
                  echo "remote url for $branch not updated"
                fi
              fi
            fi
            ((index++))
            local prev_url=$url
            local prev_branch=$branch
          done
        fi
      fi
    done
  cd $WORKING_DIR
  done
}

main "$@"
