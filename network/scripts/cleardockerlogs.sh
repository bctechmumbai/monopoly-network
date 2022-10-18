#!/bin/bash

if [ -z "$1" ]; then
   CONTAINER_NAME=""
   echo "Err:- Container Name or ID is missing.. exiting..."
   exit
else
   CONTAINER_NAME="$1"
fi

truncate -s 0 $(docker inspect --format='{{.LogPath}}' ${CONTAINER_NAME})