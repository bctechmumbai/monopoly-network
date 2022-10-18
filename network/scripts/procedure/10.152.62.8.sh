#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

./0-clean.sh
./1-start_tlsca.sh

chown -R bepds:bepds /blockchain_network

## Create the folder structure on every node and transfer the TLS CA Certfiles
#mkdir -p /blockchain_network/CA_ROOT/CAs/tlsca.mhbcn.gov.in/
 

ssh bepds@10.152.62.6 mkdir -p ${TLS_CA_CRYPTO_PATH}
rsync -a ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.6:${TLS_CA_ROOT_TLS_CERTFILES}
#rsync -a ${TLS_CA_ROOT_CERTFILES} bepds@10.152.62.6:${TLS_CA_ROOT_CERTFILES}

ssh bepds@10.152.62.7 mkdir -p ${TLS_CA_CRYPTO_PATH}
rsync -a ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.7:${TLS_CA_ROOT_TLS_CERTFILES}
#rsync -a ${TLS_CA_ROOT_CERTFILES} bepds@10.152.62.7:${TLS_CA_ROOT_CERTFILES}

ssh bepds@10.152.62.9 mkdir -p ${TLS_CA_CRYPTO_PATH}
rsync -a ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.9:${TLS_CA_ROOT_TLS_CERTFILES}
#rsync -a ${TLS_CA_ROOT_CERTFILES} bepds@10.152.62.9:${TLS_CA_ROOT_CERTFILES}

ssh bepds@10.152.62.10 mkdir -p ${TLS_CA_CRYPTO_PATH}
rsync -a ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.10:${TLS_CA_ROOT_TLS_CERTFILES}
#rsync -a ${TLS_CA_ROOT_CERTFILES} bepds@10.152.62.10:${TLS_CA_ROOT_CERTFILES}


./3-registerPeerOrganization.sh treasury.bepds.gov.in treasury peer2
./3-registerPeerOrganization.sh fci.bepds.gov.in fci peer2

export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer3.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=treasury.bepds.gov.in
export ORG_NAME_SHORT=treasury
export ORG_MSP=TREASURYMSP
export PEER1_PORT=7101
export COUCH1_PORT=5121
export PEER1_CHAINCODELISTENPORT=7103
export PEER2_PORT=7102
export COUCH2_PORT=5122
export PEER2_CHAINCODELISTENPORT=7104

./4-startPeer.sh treasury.bepds.gov.in treasury peer2

export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer3.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=fci.bepds.gov.in
export ORG_NAME_SHORT=fci
export ORG_MSP=FCIMSP
export PEER1_PORT=7081
export COUCH1_PORT=5101
export PEER1_CHAINCODELISTENPORT=7083
export PEER2_PORT=7082
export COUCH2_PORT=5102
export PEER2_CHAINCODELISTENPORT=7084

./4-startPeer.sh fci.bepds.gov.in fci peer2

##Register Orderer 
export $(grep -v '^#' ../.env | xargs)

./5-registerOrdererOrganization.sh mhbcn.gov.in mhbcn orderer3

##Start Orderer3
## Make sure the genesis block is generated and transferred to this node

./8-startOrderer.sh mhbcn.gov.in mhbcn orderer3


## Peers Join Channel on peer shell by docker exec -it sh

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fciAdmin@fci.bepds.gov.in/msp"
export CORE_PEER_TLS_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fciAdmin@fci.bepds.gov.in/tls"

peer channel join -b channelArtifacts/mahapdschannel.block

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/treasuryAdmin@treasury.bepds.gov.in/msp"
export CORE_PEER_TLS_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/treasuryAdmin@treasury.bepds.gov.in/tls"

peer channel join -b channelArtifacts/mahapdschannel.block


