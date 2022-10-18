
export $(grep -v '^#' ../.env | xargs)

docker rm $(docker ps -aq --filter "name=${PROJECT_NAME}") --force
# docker image rm $(docker images --filter 'reference=dev*bepds*' -aq ) 
docker volume prune
docker network prune

rm -rf ${PROJECT_CRYPTO_PATH}
rm -rf ${CA_CRYPTO_PATH}
rm -rf ${TLS_CA_CRYPTO_PATH}
rm -rf ${CA_CLIENT_PATH}
rm -rf ${TLS_CA_CLIENT_PATH}
rm -rf ${ROOT_CA_CLIENT_PATH}
rm -rf ${PROJECT_NETWORK_PATH}/productionvolumes
rm -rf ${GENESIS_BLOCK_PATH}
rm -rf ${CHANNEL_TX_OUTPUT_PATH}

#unset $(grep -v '^#' .env | xargs)

docker network create -d overlay --attachable vyapar_network
docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/capostgres.yaml up -d
sleep 5s

# netsh interface portproxy add v4tov4 listenport=2377 listenaddress=0.0.0.0 connectport=2377 connectaddress= 192.168.65.3
# netsh interface portproxy add v4tov4 listenport=7946 listenaddress=0.0.0.0 connectport=7946 connectaddress= 192.168.65.3
# netsh interface portproxy add v4tov4 listenport=4789 listenaddress=0.0.0.0 connectport=4789 connectaddress= 192.168.65.3
