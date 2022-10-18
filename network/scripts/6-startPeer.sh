#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

if [ -z "$1" ]; then
   ORG_NAME=""
   echo "Err:- Peer Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi


if [ -z "$2" ]; then
   ORG_NAME_SHORT=""
   echo "Err:- Peer Organization short name is missing.. exiting..."
   exit
else
   ORG_NAME_SHORT="$2"
fi

if [ -z "$3" ]; then
   PEER_NAME=""
   echo "Err:- Peer name is missing.. exiting..."
   exit
else
   PEER_NAME="$3"
fi

# export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer1.mhbcn.gov.in/tls/tlscacerts

# export ORG_NAME=${ORG_NAME}
# export ORG_NAME_SHORT=${ORG_NAME_SHORT}
# export ORG_MSP=FPSMSP
# export PEER1_PORT=7071
# export COUCH1_PORT=5091
# export PEER2_PORT=7072 
# export COUCH2_PORT=5092
# export PEER_CHAINCODELISTENPORT=7050

docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/${ORG_NAME_SHORT}_peers.yaml up -d ${PEER_NAME}.${ORG_NAME_SHORT}


