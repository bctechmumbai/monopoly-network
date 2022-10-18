#!/bin/bash

source "./utils/base-functions.sh"
source "./utils/enrollCAClient.sh"
source "./utils/enrollOrgUser.sh"
source "./utils/registerOrgUser.sh"

export $(grep -v '^#' ../.env | xargs)

export PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}


# if ! [ -d "${ROOT_CA_CLIENT_PATH}" ]; then
#    echo ""
#    textColor "ROOT TLS CA Client is not Registered," 2
#    echo "Registering ROOT TLS CA Client with default credentials."

#    enrollCAClient ${ROOT_CA_CLIENT_PATH} ${ROOT_CA_ADMIN_NAME} ${ROOT_CA_ADMIN_PASSWORD} ${ROOT_CA_NAME} ${ROOT_CA_URL} ${ROOT_CA_ROOT_TLS_CERTFILES} ${ROOT_CA_CLIENT_PROFILE_FILE}

# else
#    echo ""
#    textColor "ROOT TLS CA Client is already Registered," 1
#    echo ""
#    inputLog "ROOT_CA_CLIENT_PATH: ${ROOT_CA_CLIENT_PATH}"
#    echo ""
# fi


# # Register tlsca bootstrap user with root ca

# echo ""
# echo "Register TLS's ${TLS_CA_ADMIN_NAME} user on Root TLS CA Server.. "
# echo ""

#     ATTR='"hf.IntermediateCA=true"' # included for intermediate CA user only 
# 	registerOrgUser ${ROOT_CA_CLIENT_PATH} ${TLS_CA_ADMIN_NAME} ${TLS_CA_ADMIN_PASSWORD} client ${ROOT_CA_NAME} ${ROOT_CA_ROOT_TLS_CERTFILES} ${TLS_CA_ADMIN_ID_AFFILICATION} ${ATTR}
# 	# fabric-ca-client identity list -u https://${ROOT_CA_URL} --tls.certfiles ${ROOT_CA_ROOT_TLS_CERTFILES}


printHeadline "Starting TLS CA Server for 'Blockchain Netowrk'" "U1F913"

textColor "Configuration" 6
inputLog "TLS_CA_NAME: ${TLS_CA_NAME}"
inputLog "FABRIC_CA_VERSION: ${FABRIC_CA_VERSION}"
inputLog "TLS_CA_SERVER_PORT: ${TLS_CA_SERVER_PORT}"
inputLog "TLS_CA_CRYPTO_PATH: ${TLS_CA_CRYPTO_PATH}"
inputLog "TLS_CA_SERVER_PROFILE_FILE: ${TLS_CA_SERVER_PROFILE_FILE}"
inputLog "DOCKER_FILE: ${PROJECT_DOCKER_FILE_PATH}/tlsca.yaml"
inputLog "DOCKER_NETWORK_NAME: ${DOCKER_NETWORK_NAME}"

inputLog "TLS_CA_ADMIN_NAME: ${TLS_CA_ADMIN_NAME}"
inputLog "TLS_CA_ADMIN_PASSWORD: ${TLS_CA_ADMIN_PASSWORD}"

## Start TLS CA Server
rm -Rf ${TLS_CA_CRYPTO_PATH}

mkdir -p ${TLS_CA_CRYPTO_PATH}
sleep 1s
cp ${TLS_CA_SERVER_PROFILE_FILE} "${TLS_CA_CRYPTO_PATH}/fabric-ca-server-config.yaml"
sleep 1s
docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/tlsca.yaml  up -d tlsca
sleep 3s
# docker logs --tail 5 ${TLS_CA_NAME}
docker ps --filter "name=${TLS_CA_NAME}"











# ssh bepds@10.152.62.6 mkdir -p ${TLS_CA_CRYPTO_PATH}

# scp -r ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.6:${TLS_CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.7 mkdir -p ${TLS_CA_CRYPTO_PATH}

# scp -r ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.7:${TLS_CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.9  mkdir -p ${TLS_CA_CRYPTO_PATH}

# scp -r ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.9:${TLS_CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.10  mkdir -p ${TLS_CA_CRYPTO_PATH}

# scp -r ${TLS_CA_ROOT_TLS_CERTFILES} bepds@10.152.62.10:${TLS_CA_ROOT_TLS_CERTFILES}



