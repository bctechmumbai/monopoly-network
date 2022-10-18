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
   ORG_NAME_SHORT=""
   echo "Err:- ORG_NAME_SHORT is missing.. exiting..."
   exit
else
   ORG_NAME_SHORT="$2"
fi

# if [ -z "$3" ]; then
#    PEER_PORT=""
#    echo "Err:- Peer Port is missing.. exiting..."
#    exit
# else
#    PEER_PORT="$3"
# fi

if [ -z "$3" ]; then
   CHANNEL_NAME=""
   echo "Err:- Channel Name missing.. exiting..."
   exit
else
   CHANNEL_NAME="$3"
fi


ANCHOR_TX_FILE="${CHANNEL_TX_OUTPUT_PATH}/${ORG_NAME_SHORT}_Anchors_on_${CHANNEL_NAME}".tx

echo ""
printHeadline "Registering Organization's Anchor Peer on 'Blockchain Netowrk'" "U1F913"
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"
inputLog "ANCHOR_TX_FILE: ${ANCHOR_TX_FILE}"

echo ""


docker exec -it cli.${ORG_NAME} peer channel update -c ${CHANNEL_NAME} -f ${ANCHOR_TX_FILE} -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}


inputLog "Anchor peer updated Successfully for  ${ORG_NAME} on ${CHANNEL_NAME} .....!"


