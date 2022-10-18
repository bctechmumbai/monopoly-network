#!/bin/bash

source "./utils/base-functions.sh"

export $(grep -v '^#' ../.env | xargs)

export PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}


if [ -z "$1" ]; then
   CHANNEL_NAME=""
    echo "Err:- Channel name is missing.. exiting..."
   exit
else
   CHANNEL_NAME="$1"
fi

if [ -z "$2" ]; then
   CHANNEL_CONFIG_PROFILE=""
    echo "Err:- Channel Config Profile name is missing.. exiting..."
   exit
else
   CHANNEL_CONFIG_PROFILE="$2"
fi

if [ -z "$3" ]; then
   ORG_NAME_SHORT=""
    echo "Err:- Organization name in short is missing.. exiting..."
   exit
else
   ORG_NAME_SHORT="$3"
fi


printHeadline "Generating Anchor Peer Update config for '${ORG_NAME}' on channel '${CHANNEL_NAME}'" "U1F913"
   
ANCHOR_TX_FILE="${CHANNEL_TX_OUTPUT_PATH}/${ORG_NAME_SHORT}_Anchors_on_${CHANNEL_NAME}".tx
ORG_MSP=${ORG_NAME_SHORT}MSP

echo ""  
echo "Creating Anchor Peer Update config with channel '${CHANNEL_NAME}'..."
inputLog "CONFIG_PATH: ${FABRIC_CONFIG_PATH}"
inputLog "CONFIG_PROFILE: ${CHANNEL_CONFIG_PROFILE}"
inputLog "ANCHOR_TX_OUTPUT_PATH: ${CHANNEL_TX_OUTPUT_PATH}"
inputLog "ANCHOR_TX_FILE: ${ANCHOR_TX_FILE}"
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "ORG_NAME_SHORT: ${ORG_NAME_SHORT}"
inputLog "ORG_MSP: ${ORG_MSP}"

echo ""

if [ -f "${ANCHOR_TX_FILE}" ]; then
   echo "Can't create channel configuration, it already exists : ${ANCHOR_TX_FILE}"
   echo "Try using 'reboot' or 'down' to remove whole network or 'start' to reuse it"
   exit 1
fi

mkdir -p ${CHANNEL_TX_OUTPUT_PATH}
echo "Executing...."
echo "configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile ${CHANNEL_CONFIG_PROFILE} -outputAnchorPeersUpdate ${ANCHOR_TX_FILE} -channelID ${CHANNEL_NAME} -asOrg ${ORG_MSP}"
configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile ${CHANNEL_CONFIG_PROFILE} -outputAnchorPeersUpdate ${ANCHOR_TX_FILE} -channelID ${CHANNEL_NAME} -asOrg ${ORG_MSP}

#configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile ${CHANNEL_CONFIG_PROFILE} -outputCreateChannelTx ${CHANNEL_TX_FILE} -channelID ${CHANNEL_NAME}

# configtxgen -profile mychannel -outputAnchorPeersUpdate artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP


