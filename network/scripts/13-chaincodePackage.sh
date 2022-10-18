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
   CHAINCODE_NAME=""
   echo "Err:- CHAINCODE_NAME is missing.. exiting..."
   exit
else
   CHAINCODE_NAME="$2"
fi

if [ -z "$3" ]; then
   CHAINCODE_LANGUAGE=""
   echo "Err:- CHAINCODE_LANGUAGE is missing.. exiting..."
   exit
else
   CHAINCODE_LANGUAGE="$3"
fi


# if [ -z "$3" ]; then
#    PEER_PORT=""
#    echo "Err:- Peer Port is missing.. exiting..."
#    exit
# else
#    PEER_PORT="$3"
# fi

# if [ -z "$4" ]; then
#    PACKAGE_NAME=""
#    echo "Err:- Chaincode Package Name is missing.. exiting..."
#    exit
# else
#    PACKAGE_NAME="$4"
# fi 
echo ""
textColor "Configuration" 6
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "CHAINCODE : chaincode-packages/${CHAINCODE_NAME}"
inputLog "PACKAGE : ${CHAINCODE_NAME}.tar.gz"
inputLog "CHAINCODE_LABEL: ${CHAINCODE_NAME}"
inputLog "CHAINCODE_LANGUAGE: ${CHAINCODE_LANGUAGE}"
echo ""

#docker exec -it cli.${ORG_NAME} peer lifecycle chaincode package chaincode-packages/${CHAINCODE_NAME}.tar.gz --path chaincode-packages/${CHAINCODE_NAME}  --lang node --label ${CHAINCODE_NAME}
docker exec -it cli.${ORG_NAME} peer lifecycle chaincode package chaincode-packages/${CHAINCODE_NAME}.tar.gz --path chaincode-packages/${CHAINCODE_NAME}  --lang ${CHAINCODE_LANGUAGE} --label ${CHAINCODE_NAME}

echo ""
textColor "Chaincode Package created successfully" 2
ls -la ${CHAINCODE_PACKAGES}/${CHAINCODE_NAME}.tar.gz
echo ""