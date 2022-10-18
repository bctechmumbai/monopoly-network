#!/bin/bash
source "./utils/base-functions.sh"
source "./utils/configUpdate.sh"

export $(grep -v '^#' ../.env | xargs)

PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}

createAnchorPeerUpdate() {

   echo "" 
   inputLog "Fetching channel config for channel ${CHANNEL_NAME}"
   echo ""

   docker exec -it cli.${ORG_NAME} peer channel fetch config channelArtifacts/config_block.pb -o ${ACTIVE_ORDERER_URL} -c ${CHANNEL_NAME} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}
   configtxlator proto_decode --input ../channelArtifacts/config_block.pb --type common.Block --output ../channelArtifacts/config_block.json
   jq .data.data[0].payload.data.config ../channelArtifacts/config_block.json >../channelArtifacts/extracted_config.json

   echo "" 
   inputLog "Fetched Latest block from channel $CHANNEL_NAME"
   echo ""

   HOST=${ANCHOR_PEER_NAME}
   PORT=${ANCHOR_PEER_PORT}
   MSP=${ORG_MSP_NAME}
   
   echo ""
   inputLog "Generating anchor peer update transaction for ${ORG_NAME} on channel $CHANNEL_NAME with Anchor Peer '${HOST}:${PORT}' "
   echo ""

   jq '.channel_group.groups.Application.groups.'${MSP}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'${HOST}'","port": '${PORT}'}]},"version": "0"}}' ../channelArtifacts/extracted_config.json > ../channelArtifacts/${ORG_NAME}-modified-config.json

   echo ""
   inputLog "Generated anchor peer update transaction for ${ORG_NAME} on channel $CHANNEL_NAME with Anchor Peer '${HOST}:${PORT}' "
   echo ""



   echo ""
   echo "Generating Original config Proto block"
   echo ""
   configtxlator proto_encode --input ../channelArtifacts/extracted_config.json --type common.Config --output ../channelArtifacts/original_config.pb
   sleep 1s
 
   echo ""
   echo "Generated Original config Proto block"
   echo ""
  
   echo ""
   echo "Generating modified config Proto block"
   echo ""
   configtxlator proto_encode --input ../channelArtifacts/${ORG_NAME}-modified-config.json --type common.Config --output ../channelArtifacts/${ORG_NAME}-modified-config.pb
   sleep 1s
   echo ""
   echo "Generated modified config Proto block"
   echo ""

   echo ""
   echo "Computing difference between original and modified config Proto block"
   echo ""
   configtxlator compute_update --channel_id ${CHANNEL_NAME} --original ../channelArtifacts/original_config.pb --updated ../channelArtifacts/${ORG_NAME}-modified-config.pb --output ../channelArtifacts/${ORG_NAME}-config-update.pb
   sleep 1s 
   echo ""
   echo "Computed difference between original and modified config Proto block"
   echo ""
   
   echo ""
   echo "convert difference block to json for envelope"
   echo ""
   configtxlator proto_decode --input ../channelArtifacts/${ORG_NAME}-config-update.pb --type common.ConfigUpdate --output ../channelArtifacts/${ORG_NAME}-config-update.json
   sleep 3s
   echo ""
   echo "converted difference block to json for envelope"
   echo ""
   
   echo ""
   echo "Generating envelope"
   echo ""
   echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat ../channelArtifacts/${ORG_NAME}-config-update.json)'}}}' | jq . >../channelArtifacts/${ORG_NAME}-config_update_in_envelope.json
   sleep 1s
   echo ""
   echo "Generated envelope"
   echo ""

   echo ""
   echo "Generated Anchro update transaction"
   echo ""
   configtxlator proto_encode --input ../channelArtifacts/${ORG_NAME}-config_update_in_envelope.json --type common.Envelope --output ../channelArtifacts/${ORG_NAME}-Anchors.tx
   sleep 1s
   echo ""
   echo "Generated Anchro update transaction"
   echo ""

   ## Sign the update tx file
   echo "Sign the update tx file"
   echo ""

   docker exec -it cli.${ORG_NAME} peer channel signconfigtx -f channelArtifacts/${ORG_NAME}-Anchors.tx 
   echo ""
   echo "Signed update tx file"
   echo ""

   docker exec -it cli.${ORG_NAME} peer channel update -c ${CHANNEL_NAME} -f channelArtifacts/${ORG_NAME}-Anchors.tx -o ${ACTIVE_ORDERER_URL} --tls --cafile ${ACTIVE_ORDERER_ROOT_TLS_CERTFILE}

   echo "Anchor peer set for org ' ${ORG_NAME}' on channel '$CHANNEL_NAME'"
   
}


if [ -z "$1" ]; then
   ORG_NAME=""
   echo "Err:- Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi

if [ -z "$2" ]; then
   ORG_MSP_NAME=""
   echo "Err:- Organization MPSP ID is missing.. exiting..."
   exit
else
   ORG_MSP_NAME="$2"
fi

if [ -z "$3" ]; then
   CHANNEL_NAME=""
   echo "Err:- Channel name is missing.. exiting..."
   exit
else
   CHANNEL_NAME="$3"
fi


if [ -z "$4" ]; then
   ANCHOR_PEER_NAME=""
   echo "Err:- ANCHOR_PEER_NAME is missing provided.. exiting..."
   exit
else
   ANCHOR_PEER_NAME="$4".${ORG_NAME}
fi

if [ -z "$5" ]; then
   ANCHOR_PEER_PORT=""
   echo "Err:- ANCHOR_PEER_PORT is missing provided.. exiting..."
   exit
else
   ANCHOR_PEER_PORT="$5"
fi

# ORDERER_ADDRESS=orderer1.mhbcn.gov.in:7051
# ORERER_TLS_CERT_FILE=/var/hyperledger/fabric/cli/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

echo ""
printHeadline "Registering Organization's Anchor Peer on 'Blockchain Netowrk'" "U1F913"

echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "ORG_MSP_NAME: ${ORG_MSP_NAME}"
inputLog "CHANNEL_NAME: ${CHANNEL_NAME}"
inputLog "ANCHOR_PEER_NAME: ${ANCHOR_PEER_NAME}"
inputLog "ANCHOR_PEER_PORT: ${ANCHOR_PEER_PORT}"
inputLog "ORDERER_ADDRESS: ${ORDERER_ADDRESS}"
inputLog "ORERER_TLS_CERT_FILE: ${ORERER_TLS_CERT_FILE}"

echo ""

sleep 2s


createAnchorPeerUpdate






