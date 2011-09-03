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


puts() {
  if ! [[ $SILENT_FLAG ]]; then
    echo "$1"
  fi
}

execute_git() {
  local git_dir=$1
  shift
  git --git-dir=$git_dir/.git --work-tree=$git_dir $*
}


usage() {
  cat << EOF
usage: git url-sub [cs] <pattern> <replacement>

OPTIONS:
  -h  Shows this message
  -c  Commit changes
  -s  Silently executes

NOTE: will not commit changes by default, run with -c option to commit changes
EOF
}

escape_url() {
  echo $1 | awk '
    BEGIN {
      FS = ""
    }
    {
      result = ""
      for (i=1; i<=NF; i++) {
        if ($i == "." || $i == "/") {
          result = (result "" (result = "\\"))
        }
        result = (result "" (result = $i))
      }
      print result
    }
  '
}


main() {
  # parse options
  while getopts hsc OPTION
  do
    case $OPTION in
      h)
        usage
        exit 1
        ;;
      c)
        COMMIT=true
        ;;
      s)
        SILENT_FLAG=true
        ;;
      ?)
        usage
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  # check to see if we have both urls
  if [ $# -lt 2 ]
  then
    usage
    exit 1
  fi

  local PATTERN=$1
  local REPLACEMENT=$2

  for dir in $(echo $(find . -type dir | grep -v .git) | tr " " "\n")
  do
    if [[ $(execute_git $dir status 2> /dev/null) != "" ]]; then
      local git_remote_info=($(execute_git $dir remote -v))
      local index=0
      if [[ $(echo ${git_remote_info[@]} | grep -c $PATTERN) > 0 ]]; then
        local changes_flag=true
        for branch_info in ${git_remote_info[@]}
        do
          if [[ "$branch_info" = "(fetch)" ]] || [[ "$branch_info" = "(push)" ]]
          then
            local mode=$branch_info
            local url=${git_remote_info[$index-1]}
            local branch=${git_remote_info[$index-2]}
            local escaped=$(escape_url $PATTERN)
            local new_url=$(awk "
              BEGIN {
                str=\"$url\"
                sub(/$escaped/,\"$REPLACEMENT\",str)
                print str}
            ")
            if [[ $COMMIT ]]; then
              execute_git $dir remote set-url $branch $new_url
            fi
            puts "$dir $branch $mode $url -> $new_url"
          fi
          ((index++))
        done
      fi
    fi

  done
  if [[ $changes_flag ]]; then
    puts ""
    if [[ $COMMIT ]]; then
      puts "Changes have been made to the above urls"
    else
      puts "NOTE: No changes have been made. Please run with -c flag to commit changes"
      puts "git sub url -c $PATTERN $REPLACEMENT"
    fi
  fi
}

main "$@"
