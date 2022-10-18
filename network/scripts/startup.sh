./0-clean.sh

# ./1-start_rootca.sh
# sleep 3s
./2-start_tlsca.sh
sleep 3s
./3-start_ca.sh
sleep 3s

sleep 1s
# bepds chian organization registration
export BCN_NAME=vyapar

./4-registerPeerOrganization.sh playstationone.vyapar.bcngame.in playstationone peer1
./4-registerPeerOrganization.sh playstationone.vyapar.bcngame.in playstationone peer2
./4-registerPeerOrganization.sh playstationone.vyapar.bcngame.in playstationone peer3


./4-registerPeerOrganization.sh playstationtwo.vyapar.bcngame.in playstationtwo peer1
./4-registerPeerOrganization.sh playstationtwo.vyapar.bcngame.in playstationtwo peer2
./4-registerPeerOrganization.sh playstationtwo.vyapar.bcngame.in playstationtwo peer3
./4-registerPeerOrganization.sh playstationtwo.vyapar.bcngame.in playstationtwo peer4



# Orderer organization registration
./5-registerOrdererOrganization.sh vyapar.bcngame.in vyapar orderer1
./5-registerOrdererOrganization.sh vyapar.bcngame.in vyapar orderer2
./5-registerOrdererOrganization.sh vyapar.bcngame.in vyapar orderer3
./5-registerOrdererOrganization.sh vyapar.bcngame.in vyapar orderer4
./5-registerOrdererOrganization.sh vyapar.bcngame.in vyapar orderer5


#6-startPeer.sh
./startallpeers.sh


./7-createGenesisBlock.sh



sleep 1s
./8-startOrderer.sh vyapar.bcngame.in vyapar orderer1
./8-startOrderer.sh vyapar.bcngame.in vyapar orderer2
./8-startOrderer.sh vyapar.bcngame.in vyapar orderer3
./8-startOrderer.sh vyapar.bcngame.in vyapar orderer4
./8-startOrderer.sh vyapar.bcngame.in vyapar orderer5



./9-createchannelartifacts.sh vyaparchannel vyaparchannel

## Generate Anchor peer channel artifacts for mahapds channel.
./9-createAnchorpeerTx.sh vyaparchannel vyaparchannel PLAYSTATIONONE


# ./startallcli.sh


sleep 1s

./10-createChannel.sh playstationone.vyapar.bcngame.in vyaparchannel



./11-joinChannel.sh playstationone.vyapar.bcngame.in peer1 9011 vyaparchannel
./11-joinChannel.sh playstationone.vyapar.bcngame.in peer2 9012 vyaparchannel
./11-joinChannel.sh playstationone.vyapar.bcngame.in peer3 9013 vyaparchannel


./12-updateAnchorTx.sh playstationone.vyapar.bcngame.in PLAYSTATIONONE vyaparchannel


./deployChaincode.sh
