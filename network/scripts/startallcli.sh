#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

export ORDERER_TLS_CRYPTO_PATH=${PROJECT_ROOT_PATH}/Organizations/ordererOrganizations/${ORDERER_ORG_NAME}/orderers/${ACTIVE_ORDERER_NAME}/tls/signcerts

export ORG_NAME=playstationone.vyapar.bcngame.in
export ORG_NAME_SHORT=playstationone
export ORG_MSP=PLAYSTATIONONEMSP

export PEER1_PORT=9011
export COUCH1_PORT=5191
export PEER1_CHAINCODELISTENPORT=9021

export PEER2_PORT=9012
export COUCH2_PORT=5192
export PEER2_CHAINCODELISTENPORT=9022

export PEER3_PORT=9013
export COUCH3_PORT=5193
export PEER3_CHAINCODELISTENPORT=9023

./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} cli

