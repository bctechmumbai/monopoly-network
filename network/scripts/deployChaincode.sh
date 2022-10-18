

./13-chaincodePackage.sh playstationone.vyapar.bcngame.in vyaparcode node

./13-installChaincodePackage.sh playstationone.vyapar.bcngame.in peer1 9011 vyaparcode.tar.gz 

./13-installChaincodePackage.sh playstationtwo.vyapar.bcngame.in peer1 9014 vyaparcode.tar.gz 

# ./13-installChaincodePackage.sh playstationone.vyapar.bcngame.in peer2 9012 vyaparcode.tar.gz 
# ./13-installChaincodePackage.sh playstationone.vyapar.bcngame.in peer3 9013 vyaparcode.tar.gz 

./14-approveChaincode.sh playstationone.vyapar.bcngame.in peer1 vyaparchannel vyaparcode vyaparcode:60213e5be00e92b54f5385310c7cb1c0b7596978b9267304c43e1fcdba9f1d0d 1.15 15

./15-commitChaincode.sh playstationone.vyapar.bcngame.in peer1.playstationone.vyapar.bcngame.in:9011 vyaparchannel vyaparcode 1.15 15 playstationone


echo "--------------------writing test Transaction ---------------------------"
docker exec -it cli.playstationone.vyapar.bcngame.in peer chaincode  invoke --channelID vyaparchannel --name vyaparcode -o orderer1.vyapar.bcngame.in:9001 --tls  --cafile /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
-c '{"Args":["createAsset","{ \"assetId\":\"T1\", \"depotName\": \"Manmad\",\"schemeCode\":\"1\",\"schemeName\": \"AAY\",\"commodityCode\":\"1\",\"commodityName\": \"Wheat\",\"quantity\":\"100\"}"]}'



echo "--------------------Reading test Transaction ---------------------------"
docker exec -it cli.playstationone.vyapar.bcngame.in peer chaincode  invoke --channelID vyaparchannel --name vyaparcode -o orderer1.vyapar.bcngame.in:9001 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
-c '{"Args":["readAsset","{ \"assetId\":\"T1\"}"]}'

echo "--------------------Update test Transaction ---------------------------"
docker exec -it cli.playstationone.vyapar.bcngame.in peer chaincode  invoke --channelID vyaparchannel --name vyaparcode -o orderer1.vyapar.bcngame.in:9001 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
-c '{"Args":["updateAsset","{ \"assetId\":\"LOC-01\", \"placerent\": 0,\"placecost\":0}"]}'


peer chaincode  query --channelID vyaparchannel --name vyaparcode -c '{"Args":["readAsset","{ \"assetId\":\"T1\", \"selector\":{ \"assetType\":\"BOC\"}}"]}'

peer chaincode  invoke --channelID vyaparchannel --name vyaparcode -o orderer1.vyapar.bcngame.in:9001 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
-c '{"Args":["readAssetByParam","{ \"selector\": { \"assetData\": { \"assetType\": \"LOC\" } }}"]}'

peer chaincode  query --channelID vyaparchannel --name vyaparcode -c '{"Args":["readAssetByParam","{ \"selector\": { \"assetData\": { \"assetType\": \"LOC\" } }}"]}'

peer chaincode  query --channelID vyaparchannel --name vyaparcode -c '{"Args":["getAssetHistory","{ \"assetId\":\"T1\" }"]}'


docker exec -it cli.playstationone.vyapar.bcngame.in peer chaincode  invoke --channelID vyaparchannel --name vyaparcode -o orderer1.vyapar.bcngame.in:9001 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.playstationone.vyapar.bcngame.in:9011 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/playstationoneAdmin@playstationone.vyapar.bcngame.in/tls/ca.crt \
-c '{"Args":["vyaparContract:createGame"]}'