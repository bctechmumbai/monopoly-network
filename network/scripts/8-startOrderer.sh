#!/bin/bash

export $(grep -v '^#' ../.env | xargs)
source "./utils/base-functions.sh"

if [ -z "$1" ]; then
   ORDERER_ORG_NAME=""
   echo "Err:- Orderer Organization name is missing.. exiting..."
   exit
else
   ORDERER_ORG_NAME="$1"
fi


if [ -z "$2" ]; then
   ORDERER_ORG_NAME_SHORT=""
   echo "Err:- Orderer Organization short name is missing.. exiting..."
   exit
else
   ORDERER_ORG_NAME_SHORT="$2"
fi

if [ -z "$3" ]; then
   ORDERER_NO=""
   echo "Err:- Orderer name is missing.. exiting..."
   exit
else
   ORDERER_NO="$3"
fi

export ORDERER_ORG_NAME=${ORDERER_ORG_NAME}
export ORDERER_ORG_NAME_SHORT=${ORDERER_ORG_NAME_SHORT}
export ORDERER_ORG_MSP=VYAPARMSP #${ORDERER_ORG_NAME_SHORT}MSP
export ORDERER_NAME=${ORDERER_NO}.${ORDERER_ORG_NAME}
export ORDERER_ORG_CRYPTO_PATH=${PROJECT_ROOT_PATH}/Organizations/ordererOrganizations/${ORDERER_ORG_NAME}

echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORDERER_ORG_NAME}"
inputLog "ORG_NAME_SHORT: ${ORDERER_ORG_NAME_SHORT}"
inputLog "ORG_ORG_MSP: ${ORDERER_ORG_MSP}"
inputLog "ORDERER_NAME: ${ORDERER_NAME}"
inputLog "ORG_CRYPTO_PATH: ${ORDERER_ORG_CRYPTO_PATH}"

inputLog "PROJECT_DOCKER_FILE_PATH: ${PROJECT_DOCKER_FILE_PATH}"


echo ""

   
docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/orderers.yaml up -d ${ORDERER_NO}