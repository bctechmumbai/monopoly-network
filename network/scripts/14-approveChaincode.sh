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
   PEER_NAME=""
   echo "Err:- Peer name is missing.. exiting..."
   exit
else
   PEER_NAME="$2"
fi

if [ -z "$3" ]; then
   CHANNEL_NAME=""
   echo "Err:- Channel Name missing.. exiting..."
   exit
else
   CHANNEL_NAME="$3"
fi


if [ -z "$4" ]; then
   CHAINCODE_NAME=""
   echo "Err:- Chaincode Name is missing.. exiting..."
   exit
else
   CHAINCODE_NAME="$4"
fi

if [ -z "$5" ]; then
   CC_PACKAGE_ID=""
   echo "Err:- Chaincode Package ID is missing.. exiting..."
   exit
else
   CC_PACKAGE_ID="$5"
fi

if [ -z "$6" ]; then
   CHAINCODE_VERSION=""
   echo "Err:- Chaincode version ID is missing.. exiting..."
   exit
else
   CHAINCODE_VERSION="$6"
fi

if [ -z "$7" ]; then
   CHAINCODE_SEQUENCE=""
   echo "Err:- Chaincode sequence is missing.. exiting..."
   exit
else
   CHAINCODE_SEQUENCE="$7"
fi

# ORDERER=orderer1.mhbcn.gov.in:7051
# ORDERER_TLS_CRYPTO=/var/hyperledger/fabric/cli/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
 
echo ""
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "PEER_NAME: ${PEER_NAME}.${ORG_NAME}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"
echo ""


inputLog "CHAINCODE_NAME: ${CHAINCODE_NAME}"
inputLog "CHAINCODE_PACKAGE_ID: ${CC_PACKAGE_ID}"
inputLog "CHAINCODE_VERSION: ${CHAINCODE_VERSION}"
inputLog "CHAINCODE_SEQUENCE: ${CHAINCODE_SEQUENCE}"
echo ""

docker exec -it cli.${ORG_NAME} peer lifecycle chaincode approveformyorg  --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --package-id $CC_PACKAGE_ID --sequence ${CHAINCODE_SEQUENCE} --waitForEvent -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}
docker exec -it cli.${ORG_NAME} peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE} --output json
