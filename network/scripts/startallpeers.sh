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

./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer1
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer2
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer3
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} cli



export ORG_NAME=playstationtwo.vyapar.bcngame.in
export ORG_NAME_SHORT=playstationtwo
export ORG_MSP=PLAYSTATIONTWOMSP

export PEER1_PORT=9014
export COUCH1_PORT=5194
export PEER1_CHAINCODELISTENPORT=9024

export PEER2_PORT=9015
export COUCH2_PORT=5195
export PEER2_CHAINCODELISTENPORT=9025

export PEER3_PORT=9016
export COUCH3_PORT=5196
export PEER3_CHAINCODELISTENPORT=9026

export PEER4_PORT=9017
export COUCH4_PORT=5197
export PEER4_CHAINCODELISTENPORT=9027

./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer1
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer2
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer3
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} peer4
./6-startPeer.sh ${ORG_NAME} ${ORG_NAME_SHORT} cli