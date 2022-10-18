#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

##Make sure both the CAs are up and running before register peers
## and host entries made accordingly

./3-registerPeerOrganization.sh fps.bepds.gov.in fps peer1
./3-registerPeerOrganization.sh transport.bepds.gov.in transport peer2

export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer5.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=fps.bepds.gov.in
export ORG_NAME_SHORT=fps
export ORG_MSP=FPSMSP
export PEER1_PORT=7071
export COUCH1_PORT=5091
export PEER1_CHAINCODELISTENPORT=7073
export PEER2_PORT=7072
export COUCH2_PORT=5092
export PEER2_CHAINCODELISTENPORT=7074

./4-startPeer.sh fps.bepds.gov.in fps peer1

export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer5.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=transport.bepds.gov.in
export ORG_NAME_SHORT=transport
export ORG_MSP=TRANSPORTMSP
export PEER1_PORT=7091
export COUCH1_PORT=5111
export PEER1_CHAINCODELISTENPORT=7093
export PEER2_PORT=7092
export COUCH2_PORT=5112
export PEER2_CHAINCODELISTENPORT=7094

./4-startPeer.sh transport.bepds.gov.in transport peer2


##Register Orderer 
export $(grep -v '^#' ../.env | xargs)

./5-registerOrdererOrganization.sh mhbcn.gov.in mhbcn orderer5

##Start Orderer5
## Make sure the genesis block is generated and transferred to this node

./8-startOrderer.sh mhbcn.gov.in mhbcn orderer5


## Peers Join Channel on peer shell by docker exec -it sh

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fpsAdmin@fps.bepds.gov.in/msp"
export CORE_PEER_TLS_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fpsAdmin@fps.bepds.gov.in/tls"

peer channel join -b channelArtifacts/mahapdschannel.block

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/transportAdmin@transport.bepds.gov.in/msp"
export CORE_PEER_TLS_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/transportAdmin@transport.bepds.gov.in/tls"

peer channel join -b channelArtifacts/mahapdschannel.block
