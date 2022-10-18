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


printHeadline "Generating config for '${CHANNEL_NAME}'" "U1F913"
   
CHANNEL_TX_FILE="${CHANNEL_TX_OUTPUT_PATH}/${CHANNEL_NAME}".tx

echo ""  
echo "Creating Genesis block with channel  '${CHANNEL_NAME}'..."
inputLog "CONFIG_PATH: ${FABRIC_CONFIG_PATH}"
inputLog "CONFIG_PROFILE: ${CHANNEL_CONFIG_PROFILE}"
inputLog "CHANNEL_TX_OUTPUT_PATH: ${CHANNEL_TX_OUTPUT_PATH}"
inputLog "CHANNEL_TX_FILE: ${CHANNEL_TX_FILE}"
echo ""

if [ -f "${CHANNEL_TX_FILE}" ]; then
   echo "Can't create channel configuration, it already exists : ${CHANNEL_TX_FILE}"
   echo "Try using 'reboot' or 'down' to remove whole network or 'start' to reuse it"
   exit 1
fi

mkdir -p ${CHANNEL_TX_OUTPUT_PATH}

configtxgen --configPath ${FABRIC_CONFIG_PATH} -profile ${CHANNEL_CONFIG_PROFILE} -outputCreateChannelTx ${CHANNEL_TX_FILE} -channelID ${CHANNEL_NAME}


