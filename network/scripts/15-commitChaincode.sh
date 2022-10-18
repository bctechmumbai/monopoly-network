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
   PEER_ADDRESS=""
   echo "Err:- Peer Address is missing.. exiting..."
   exit
else
   PEER_ADDRESS="$2"
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
   CHAINCODE_VERSION=""
   echo "Err:- Chaincode version ID is missing.. exiting..."
   exit
else
   CHAINCODE_VERSION="$5"
fi

if [ -z "$6" ]; then
   CHAINCODE_SEQUENCE=""
   echo "Err:- Chaincode sequence is missing.. exiting..."
   exit
else
   CHAINCODE_SEQUENCE="$6"
fi

if [ -z "$7" ]; then
   ORG_SHORT_NAME=""
   echo "Err:- ORG Short name at Position 7 is  missing.. exiting..."
   exit
else
   ORG_SHORT_NAME="$7"
fi


# ORDERER=orderer1.mhbcn.gov.in:7051
# ORDERER_TLS_CRYPTO=/var/hyperledger/fabric/cli/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
TLS_ROOT_CERT_FILES=/var/hyperledger/fabric/cli/users/${ORG_SHORT_NAME}Admin@${ORG_NAME}/tls/ca.crt #ica.crt
 
echo ""
echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "PEER_ADDRESS: ${PEER_ADDRESS}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"
echo ""


inputLog "CHAINCODE_NAME: ${CHAINCODE_NAME}"
inputLog "CHAINCODE_VERSION: ${CHAINCODE_VERSION}"
inputLog "CHAINCODE_SEQUENCE: ${CHAINCODE_SEQUENCE}"
echo ""

# docker exec -it cli.${ORG_NAME} peer lifecycle chaincode approveformyorg  --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --package-id $CC_PACKAGE_ID --sequence ${CHAINCODE_SEQUENCE} -o ${ORDERER} --tls --cafile ${ORDERER_TLS_CRYPTO}
docker exec -it cli.${ORG_NAME} peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE} --output json

#docker exec -it cli.${ORG_NAME} peer lifecycle chaincode commit -o ${ORDERER}  --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} --tls --cafile ${ORDERER_TLS_CRYPTO} --peerAddresses ${PEER_ADDRESS} --tlsRootCertFiles ${TLS_ROOT_CERT_FILES}  --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES}  
# --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES}
docker exec -it cli.${ORG_NAME} peer lifecycle chaincode commit -o ${ACTIVE_ORDERER_URL}  --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence ${CHAINCODE_SEQUENCE} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE} \
--peerAddresses ${PEER_ADDRESS} --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
--peerAddresses peer1.playstationtwo.vyapar.bcngame.in:9014 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} 
#\
# --peerAddresses peer1.litigant.judicialchain.gov.in:7161 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES}


#--peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
#--peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
#--peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
#--peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} 
# --peerAddresses peer1.seedca.seedchain.gov.in:7121 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
# --peerAddresses peer1.moafw.seedchain.gov.in:7131 --tlsRootCertFiles ${TLS_ROOT_CERT_FILES} \
 