#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

./0-clean.sh
./2-start_ca.sh

chown -R bepds:bepds /blockchain_network

## Create the folder structure on every node and transfer the TLS CA Certfiles
#mkdir -p /blockchain_network/CA_ROOT/CAs/tlsca.mhbcn.gov.in/

ssh bepds@10.152.62.7 mkdir -p ${CA_CRYPTO_PATH}
rsync -a ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.7:${CA_ROOT_TLS_CERTFILES}
rsync -a ${CA_ROOT_CERTFILES} bepds@10.152.62.7:${CA_ROOT_CERTFILES}

ssh bepds@10.152.62.8 mkdir -p ${CA_CRYPTO_PATH}
rsync -a ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.8:${CA_ROOT_TLS_CERTFILES}
rsync -a ${CA_ROOT_CERTFILES} bepds@10.152.62.8:${CA_ROOT_CERTFILES}

ssh bepds@10.152.62.9 mkdir -p ${CA_CRYPTO_PATH}
rsync -a ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.9:${CA_ROOT_TLS_CERTFILES}
rsync -a ${CA_ROOT_CERTFILES} bepds@10.152.62.9:${CA_ROOT_CERTFILES}

ssh bepds@10.152.62.10 mkdir -p ${CA_CRYPTO_PATH}
rsync -a ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.10:${CA_ROOT_TLS_CERTFILES}
rsync -a ${CA_ROOT_CERTFILES} bepds@10.152.62.10:${CA_ROOT_CERTFILES}

##Make sure both the CAs are up and running before register peers
## and host entries made accordingly

./3-registerPeerOrganization.sh fps.bepds.gov.in fps peer2
./3-registerPeerOrganization.sh treasury.bepds.gov.in treasury peer1

export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer1.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=fps.bepds.gov.in
export ORG_NAME_SHORT=fps
export ORG_MSP=FPSMSP
export PEER1_PORT=7071
export COUCH1_PORT=5091
export PEER1_CHAINCODELISTENPORT=7073
export PEER2_PORT=7072
export COUCH2_PORT=5092
export PEER2_CHAINCODELISTENPORT=7074

./4-startPeer.sh fps.bepds.gov.in fps peer2


export ORDERER_TLS_CRYPTO_PATH=/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer1.mhbcn.gov.in/tls/tlscacerts

export ORG_NAME=treasury.bepds.gov.in
export ORG_NAME_SHORT=treasury
export ORG_MSP=TREASURYMSP
export PEER1_PORT=7101
export COUCH1_PORT=5121
export PEER1_CHAINCODELISTENPORT=7103
export PEER2_PORT=7102
export COUCH2_PORT=5122
export PEER2_CHAINCODELISTENPORT=7104

./4-startPeer.sh treasury.bepds.gov.in treasury peer1


##Register Orderer 
export $(grep -v '^#' ../.env | xargs)

./5-registerOrdererOrganization.sh mhbcn.gov.in mhbcn orderer1


## Create global msp here to generate genesis block

mkdir transport.bepds.gov.in
mkdir fci.bepds.gov.in
mkdir fcs.bepds.gov.in

chown -R bepds:bepds /blockchain_network

## copy global msp from 10.152.62.7 peerOrganization
rsync -a /blockchain_network/Organizations/peerOrganizations/fci.bepds.gov.in/msp bepds@10.152.62.6:/blockchain_network/Organizations/peerOrganizations/fci.bepds.gov.in/
rsync -a /blockchain_network/Organizations/peerOrganizations/fcs.bepds.gov.in/msp bepds@10.152.62.6:/blockchain_network/Organizations/peerOrganizations/fcs.bepds.gov.in/

## copy global msp from 10.152.62.10 of peerOrganization

rsync -a /blockchain_network/Organizations/peerOrganizations/transport.bepds.gov.in/msp bepds@10.152.62.6:/blockchain_network/Organizations/peerOrganizations/transport.bepds.gov.in/


## 
mkdir -p /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer2.mhbcn.gov.in/tls/
mkdir -p /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer3.mhbcn.gov.in/tls/
mkdir -p /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer4.mhbcn.gov.in/tls/
mkdir -p /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer5.mhbcn.gov.in/tls/

chown -R bepds:bepds /blockchain_network
#ssh bepds@10.152.62.7 
rsync -a /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer2.mhbcn.gov.in/tls/server.crt bepds@10.152.62.6:/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer2.mhbcn.gov.in/tls/

#ssh bepds@10.152.62.8 
rsync -a /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer3.mhbcn.gov.in/tls/server.crt bepds@10.152.62.6:/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer3.mhbcn.gov.in/tls/

#ssh bepds@10.152.62.9 
rsync -a /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer4.mhbcn.gov.in/tls/server.crt bepds@10.152.62.6:/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer4.mhbcn.gov.in/tls/

#ssh bepds@10.152.62.10
rsync -a /blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer5.mhbcn.gov.in/tls/server.crt bepds@10.152.62.6:/blockchain_network/Organizations/ordererOrganizations/mhbcn.gov.in/orderers/orderer5.mhbcn.gov.in/tls/

##Generate Genesis Block for orderer

./6-createGenesisBlock.sh


## Distribute genesis block to all orderer nodes

rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.7:/blockchain_network/Network/
rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.8:/blockchain_network/Network/
rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.9:/blockchain_network/Network/
rsync -a /blockchain_network/Network/system-genesis-block bepds@10.152.62.10:/blockchain_network/Network/


./7-startOrderer.sh mhbcn.gov.in mhbcn orderer1

./8-createchannelartifacts.sh mahapdschannel mahapdschannel

rsync -a /blockchain_network/Network/channelArtifacts bepds@10.152.62.7:/blockchain_network/Network/
rsync -a /blockchain_network/Network/channelArtifacts bepds@10.152.62.8:/blockchain_network/Network/
rsync -a /blockchain_network/Network/channelArtifacts bepds@10.152.62.9:/blockchain_network/Network/
rsync -a /blockchain_network/Network/channelArtifacts bepds@10.152.62.10:/blockchain_network/Network/

##Start Orderer1



## Peers Join Channel on peer shell by docker exec -it sh

peer channel create -f channelArtifacts/mahapdschannel.tx --outputBlock channelArtifacts/mahapdschannel.block -c mahapdschannel -o orderer1.mhbcn.gov.in:7051 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fcsAdmin@fcs.bepds.gov.in/msp"
peer channel join -b channelArtifacts/mahapdschannel.block
peer channel list

peer lifecycle chaincode install chaincode/depotManager10.tar.gz
export CC_PACKAGE_ID=depotManager_1.0:94b822a2c4b594220389302657bf0529fb26de12bae8dec2762327133400a654
peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name depotManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fpsAdmin@fps.bepds.gov.in/msp"
peer channel join -b channelArtifacts/mahapdschannel.block
peer channel list

peer lifecycle chaincode install chaincode/depotManager10.tar.gz
export CC_PACKAGE_ID=depotManager_1.0:94b822a2c4b594220389302657bf0529fb26de12bae8dec2762327133400a654
peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name depotManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fciAdmin@fci.bepds.gov.in/msp"
peer channel join -b channelArtifacts/mahapdschannel.block
peer channel list

peer lifecycle chaincode install chaincode/depotManager10.tar.gz
export CC_PACKAGE_ID=depotManager_1.0:94b822a2c4b594220389302657bf0529fb26de12bae8dec2762327133400a654
peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name depotManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/transportAdmin@transport.bepds.gov.in/msp"
peer channel join -b channelArtifacts/mahapdschannel.block
peer channel list

peer lifecycle chaincode install chaincode/depotManager10.tar.gz
export CC_PACKAGE_ID=depotManager_1.0:94b822a2c4b594220389302657bf0529fb26de12bae8dec2762327133400a654
peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name depotManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/treasuryAdmin@treasury.bepds.gov.in/msp"
peer channel join -b channelArtifacts/mahapdschannel.block
peer channel list

peer lifecycle chaincode install chaincode/depotManager10.tar.gz
export CC_PACKAGE_ID=depotManager_1.0:94b822a2c4b594220389302657bf0529fb26de12bae8dec2762327133400a654
peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name depotManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem
peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

peer lifecycle chaincode commit -o orderer1.mhbcn.gov.in:7051  --channelID mahapdschannel --name depotManager --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt
peer lifecycle chaincode querycommitted --channelID mahapdschannel --name depotManager --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem














## Transfer channel block to other nodes

rsync -a /blockchain_network/Network/channelArtifacts/mahapdschannel.block bepds@10.152.62.7:/blockchain_network/Network/channelArtifacts/
rsync -a /blockchain_network/Network/channelArtifacts/mahapdschannel.block bepds@10.152.62.8:/blockchain_network/Network/channelArtifacts/
rsync -a /blockchain_network/Network/channelArtifacts/mahapdschannel.block bepds@10.152.62.9:/blockchain_network/Network/channelArtifacts/
rsync -a /blockchain_network/Network/channelArtifacts/mahapdschannel.block bepds@10.152.62.10:/blockchain_network/Network/channelArtifacts/


## Package chaincode to install on anchor peer
export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fcsAdmin@fcs.bepds.gov.in/msp"
peer lifecycle chaincode package chaincode/adminApp10.tar.gz --path chaincode/adminAppChaincodeV12/  --lang node --label adminApp_1.0

peer lifecycle chaincode package chaincode/depotManager10.tar.gz --path chaincode/depotManager/  --lang node --label depotManager_1.0

#peer lifecycle chaincode package chaincode/fabcar10.tar.gz --path chaincode/fabcar/  --lang node --label fabcar_1.0


## Install chaincode to install on anchor peer
export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fcsAdmin@fcs.bepds.gov.in/msp"
peer lifecycle chaincode install chaincode/adminApp10.tar.gz
peer lifecycle chaincode queryinstalled

# peer lifecycle chaincode install chaincode/fabcar10.tar.gz
# peer lifecycle chaincode queryinstalled


export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fpsAdmin@fps.bepds.gov.in/msp"
peer lifecycle chaincode install chaincode/adminApp10.tar.gz
peer lifecycle chaincode install chaincode/depotManager10.tar.gz
peer lifecycle chaincode queryinstalled

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/fciAdmin@fci.bepds.gov.in/msp"
peer lifecycle chaincode install chaincode/adminApp10.tar.gz
peer lifecycle chaincode queryinstalled

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/transportAdmin@transport.bepds.gov.in/msp"
peer lifecycle chaincode install chaincode/adminApp10.tar.gz
peer lifecycle chaincode queryinstalled

export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/treasuryAdmin@treasury.bepds.gov.in/msp"
peer lifecycle chaincode install chaincode/adminApp10.tar.gz
peer lifecycle chaincode queryinstalled



## Approve installed chaincode on peer
export CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/peer/users/treasuryAdmin@treasury.bepds.gov.in/msp"
export CC_PACKAGE_ID=adminApp_1.0:805ab125fadf6522deee80ce604d03858dcf5d0f2b6cf4f5d81c6c59e065b5e6

#export CC_PACKAGE_ID=depotManager_1.0:c933cd3eb049ceabfce8218a8ce9cb99ec752e995fad0b92f9f4d4b2b25bf76d

#export CC_PACKAGE_ID=fabcar_1.0:fe0c1befb492693736cf04ee7e9a8d5021ea334e91fbde275f77717df879f37f



#peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name deoptManager --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

#peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name deoptManager --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

#peer lifecycle chaincode commit -o orderer1.mhbcn.gov.in:7051  --channelID mahapdschannel --name deoptManager --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt


peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name AdminApp --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

#peer lifecycle chaincode approveformyorg -o orderer1.mhbcn.gov.in:7051 --channelID mahapdschannel --name fabcar --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name AdminApp --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

#peer lifecycle chaincode checkcommitreadiness --channelID mahapdschannel --name fabcar --version 1.0 --sequence 1 --output json --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

peer lifecycle chaincode commit -o orderer1.mhbcn.gov.in:7051  --channelID mahapdschannel --name AdminApp --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt

#peer lifecycle chaincode commit -o orderer1.mhbcn.gov.in:7051  --channelID mahapdschannel --name fabcar --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt 

peer lifecycle chaincode querycommitted --channelID mahapdschannel --name AdminApp --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem

#peer lifecycle chaincode querycommitted --channelID mahapdschannel --name fabcar --tls --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem


peer chaincode query -C mahapdschannel -n AdminApp -c '{"Args":["readNicOrders","6398"]}'



#peer chaincode  invoke --channelID mahapdschannel --name fabcar  -o orderer1.mhbcn.gov.in:7051 --tls  --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem  --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt -c '{"function":"initLedger","Args":[]}'

peer chaincode query -C mahapdschannel -n fabcar -c '{"Args":["queryAllCars"]}'

peer chaincode  invoke --channelID mahapdschannel --name fabcar  -o orderer1.mhbcn.gov.in:7051 --tls  --cafile /etc/hyperledger/fabric/peer/orderer_tls/tls-tlsca-mhbcn-gov-in-7031-tlsca-mhbcn-gov-in.pem  --peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt --peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /etc/hyperledger/fabric/peer/tls/ca.crt -c '{"function":"createCar","Args":["CAR30", "Audi", "XXX", "Black", "Lahu"]}'

peer chaincode query -C mahapdschannel -n fabcar -c '{"Args":["queryCar", "CAR35"]}'

