#!/bin/bash


source "./utils/base-functions.sh"

if [ -z "$1" ]; then
   ORG_NAME=""
   echo "Err:- Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi

if [ -z "$2" ]; then
   PEER_NAME=""
   echo "Err:- Peer name is missing.. exiting..."
   exit
else
   PEER_NAME="$2"
fi

if [ -z "$3" ]; then
   PEER_PORT=""
   echo "Err:- Peer Port is missing.. exiting..."
   exit
else
   PEER_PORT="$3"
fi

if [ -z "$4" ]; then
   CHANNEL_NAME=""
   echo "Err:- Channel Name missing.. exiting..."
   exit
else
   CHANNEL_NAME="$4"
fi
echo ""
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "PEER_NAME: ${PEER_NAME}.${ORG_NAME}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"


echo ""
inputLog "${PEER_NAME} of ${ORG_NAME} is joining channel ${CHANNEL_NAME} from CLI of ${ORG_NAME}.....!"
echo ""
echo ""
docker exec -e CORE_PEER_ADDRESS=${PEER_NAME}.${ORG_NAME}:${PEER_PORT} -it cli.${ORG_NAME} peer channel list
docker exec -e CORE_PEER_ADDRESS=${PEER_NAME}.${ORG_NAME}:${PEER_PORT} -it cli.${ORG_NAME} peer channel join -b channelArtifacts/${CHANNEL_NAME}.block
docker exec -e CORE_PEER_ADDRESS=${PEER_NAME}.${ORG_NAME}:${PEER_PORT} -it cli.${ORG_NAME} peer channel list

inputLog "Channel Joined Successfully .....!"


