#!/bin/bash

#Starting Postgres DB Server
source "./utils/base-functions.sh"
source "./utils/enrollCAClient.sh"
source "./utils/enrollOrgUserTls.sh"
source "./utils/registerOrgUser.sh"

export $(grep -v '^#' ../.env | xargs)

#moved to clean.
# docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/capostgres.yaml up -d
# sleep 5s
printHeadline "Starting ROOT TLS CA Server for 'Blockchain Netowrk'" "U1F913"

textColor "Configuration" 6
inputLog "ROOT_CA_NAME: ${ROOT_CA_NAME}"
inputLog "FABRIC_CA_VERSION: ${FABRIC_CA_VERSION}"
inputLog "ROOT_CA_SERVER_PORT: ${ROOT_CA_SERVER_PORT}"
inputLog "ROOT_CA_CRYPTO_PATH: ${ROOT_CA_CRYPTO_PATH}"
inputLog "ROOT_CA_SERVER_PROFILE_FILE: ${ROOT_CA_SERVER_PROFILE_FILE}"
inputLog "DOCKER_FILE: ${PROJECT_DOCKER_FILE_PATH}/rootca.yaml"
inputLog "DOCKER_NETWORK_NAME: ${DOCKER_NETWORK_NAME}"

inputLog "ROOT_CA_ADMIN_NAME: ${ROOT_CA_ADMIN_NAME}"
inputLog "ROOT_CA_ADMIN_PASSWORD: ${ROOT_CA_ADMIN_PASSWORD}"

## Start TLS CA Server
rm -Rf ${ROOT_CA_CRYPTO_PATH}
mkdir -p ${ROOT_CA_CRYPTO_PATH}
cp ${ROOT_CA_SERVER_PROFILE_FILE} ${ROOT_CA_CRYPTO_PATH}/fabric-ca-server-config.yaml
docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/rootca.yaml  up -d rootca
sleep 3s
# docker logs --tail 5 rootca.mhbcn.gov.in
docker ps --filter "name=${ROOT_CA_NAME}"
