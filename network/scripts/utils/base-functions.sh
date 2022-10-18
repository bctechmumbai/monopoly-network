#!/bin/bash

function printHeadline() {
  bold=$'\e[1m'
  end=$'\e[0m'

  TEXT=$1
  EMOJI=$2
  printf "${bold}============ %b %s %b ==============${end}\n" "\\$EMOJI" "$TEXT" "\\$EMOJI"
}

function printItalics() {
  italics=$'\e[3m'
  end=$'\e[0m'

  TEXT=$1
  EMOJI=$2
  printf "${italics}==== %b %s %b ====${end}\n" "\\$EMOJI" "$TEXT" "\\$EMOJI"
}

function inputLog() {
  end=$'\e[0m'
  darkGray=$'\e[90m'

  echo "${darkGray}   $1 ${end}"
}

function textColor()
{
    end=$'\e[0m'
    darkGray=$'\e[90m'

    echo "$(tput setaf $2)  $1 ${end}"
 
#0    black     COLOR_BLACK     0,0,0
#1    red       COLOR_RED       1,0,0
#2    green     COLOR_GREEN     0,1,0
#3    yellow    COLOR_YELLOW    1,1,0
#4    blue      COLOR_BLUE      0,0,1
#5    magenta   COLOR_MAGENTA   1,0,1
#6    cyan      COLOR_CYAN      0,1,1
#7    white     COLOR_WHITE     1,1,1


    
}

function inputLogShort() {
  end=$'\e[0m'
  darkGray=$'\e[90m'

  echo "${darkGray}   $1 ${end}"
}

function certsRemove() {
  local CERTS_DIR_PATH=$1
  rm -rf "$CERTS_DIR_PATH"
}

function removeContainer() {
  CONTAINER_NAME=$1
  docker rm -f "$CONTAINER_NAME"
}
