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
   PACKAGE_NAME=""
   echo "Err:- Chaincode Package Name is missing.. exiting..."
   exit
else
   PACKAGE_NAME="$4"
fi
echo ""
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "PEER_NAME: ${PEER_NAME}.${ORG_NAME}"
inputLog "CHAINCODE_PACKAGE_NAME: ${PACKAGE_NAME}"
echo ""

docker exec -e CORE_PEER_ADDRESS=${PEER_NAME}.${ORG_NAME}:${PEER_PORT} -it cli.${ORG_NAME} peer lifecycle chaincode install chaincode-packages/${PACKAGE_NAME}
docker exec -e CORE_PEER_ADDRESS=${PEER_NAME}.${ORG_NAME}:${PEER_PORT} -it cli.${ORG_NAME} peer lifecycle chaincode queryinstalled


