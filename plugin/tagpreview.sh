#!/usr/bin/env bash

REVERSE="\x1b[7m"
RESET="\x1b[m"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 TAG"
  exit 1
fi
#
# Ignore if an empty path is given
[[ -z $1 ]] && exit

FILE_AND_LINE=$(echo "$1" | awk '{print $2}')

# check if FILE_AND_LINE includes a colon
if [[ ! "$FILE_AND_LINE" =~ ^.*:.*$ ]]; then
    # get the last part of the line
    FILE_AND_LINE=$(echo "$1" | awk '{print $NF}')
fi

IFS=':' read -r -a INPUT <<< "${FILE_AND_LINE}"
FILE=${INPUT[0]}
CENTER=${INPUT[1]}

if [[ -n "$CENTER" && ! "$CENTER" =~ ^[0-9] ]]; then
  exit 1
fi
CENTER=${CENTER/[^0-9]*/}

LINE_START=$(( CENTER - 15 ))
LINE_END=$(( CENTER + 15 ))

CMD="sed -n '${LINE_START},${LINE_END}p' '$FILE'"

eval "$CMD" 2> /dev/null | awk "{ \
    if (NR == 16) \
        { gsub(/\x1b[[0-9;]*m/, \"&$REVERSE\"); printf(\"$REVERSE%s\n$RESET\", \$0); } \
    else printf(\"$RESET%s\n\", \$0); \
    }"
