#!/bin/bash

source "./utils/base-functions.sh"

export $(grep -v '^#' ../.env | xargs)

if [ -z "$1" ]; then
   ORG_NAME=""
   echo "Err:- Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi

if [ -z "$2" ]; then
   CHANNEL_NAME=""
   echo "Err:- Channel Name missing.. exiting..."
   exit
else
   CHANNEL_NAME="$2"
fi

echo ""
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"
inputLog "ORDERER_TLS_CRYPTO: ${ORDERER_TLS_CRYPTO}"
echo ""

inputLog "Createing channel block for ${CHANNEL_NAME} on CLI of ${ORG_NAME}.....!"

echo "docker exec -it cli.${ORG_NAME} peer channel create -f channelArtifacts/${CHANNEL_NAME}.tx --outputBlock channelArtifacts/${CHANNEL_NAME}.block -c ${CHANNEL_NAME} -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}"
docker exec -it cli.${ORG_NAME} peer channel create -f channelArtifacts/${CHANNEL_NAME}.tx --outputBlock channelArtifacts/${CHANNEL_NAME}.block -c ${CHANNEL_NAME} -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}
docker exec -it cli.${ORG_NAME} ls channelArtifacts/${CHANNEL_NAME}.block
echo ""
inputLog "Channel block created successfully.....!"
echo ""





