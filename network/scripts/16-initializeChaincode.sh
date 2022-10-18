
# echo "Test isExists function"
# docker exec -it cli.fcs.bepds.gov.in peer chaincode query -C mahapdschannel -n documentManager -c '{"Args":["documentExists","123"]}'

echo "Initialize Asset"
docker exec -it cli.fcs.bepds.gov.in peer chaincode  invoke --channelID mahapdschannel --name documentManager -o orderer2.mhbcn.gov.in:7052 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
-c '{"Args":["createDocument","{ \"assetId\":\"TagNo:C33185700004\",\"crop\": \"Paddy\",\"variety\":\"LALATA\",\"certclass\": \"Certified-1\",\"quantity\": \"20KG\",\"LotNumber\": \"APR19-33-028-117(2)\",\"dateOfIssue\" : \"24/02/2020\",\"growerName\" : \"Niladri B Mohanty\",\"spaName\": \"OSSC\",\"sourceStorehouse\":\"KHURDHA, PIN 753011\",\"destiStorehouse\": \"PURI, PIN 7534511\",\"certNo\":\"1234\",\"certDate\": \"09-02-2022\",\"certAuthority\": \"Seed Certificate Authority\",\"certbytes\": \"' $(cat encoded.txt) '\",\"certHash\":\"f707bca5ba87c913f9edab2bfce1b095856ae4c2695646d74b00cc490b17fd50\"}"]}'


echo ""
echo ""
echo ""
sleep 5s
echo "Read Asset"
docker exec -it cli.fcs.bepds.gov.in peer chaincode query -C mahapdschannel -n documentManager -c \
'{"Args":["readDocument","{\"assetId\":\"TagNo:C33185700004\",\"LotNumber\": \"APR19-33-028-117(2)\"}"]}'

exit

echo "Add Stock"
docker exec -it cli.fcs.bepds.gov.in peer chaincode  invoke --channelID mahapdschannel --name depotManager -o orderer2.mhbcn.gov.in:7052 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
-c '{"Args":["addStock","111","20"]}'

echo "Initialize Stock"
docker exec -it cli.fcs.bepds.gov.in peer chaincode  invoke --channelID mahapdschannel --name depotManager -o orderer2.mhbcn.gov.in:7052 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
-c '{"Args":["initializeDepot","{ \"depotCode\":\"1\",\"depotName\": \"Manmad\",\"schemeCode\":\"1\",\"schemeName\": \"AAY\",\"commodityCode\":\"1\",\"commodityName\": \"Wheat\",\"quantity\":\"100\"}"]}'

echo "Get Stock"
docker exec -it cli.fcs.bepds.gov.in peer chaincode  invoke --channelID mahapdschannel --name depotManager -o orderer2.mhbcn.gov.in:7052 --tls  --cafile /var/hyperledger/fabric/cli/orderer_tls/cert.pem \
--peerAddresses peer1.fcs.bepds.gov.in:7061 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fps.bepds.gov.in:7071 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.fci.bepds.gov.in:7081 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.transport.bepds.gov.in:7091 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
--peerAddresses peer1.treasury.bepds.gov.in:7101 --tlsRootCertFiles /var/hyperledger/fabric/cli/users/fcsAdmin@fcs.bepds.gov.in/tls/ca.crt \
-c '{"Args":["getDepotStock","111"]}'