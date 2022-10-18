#!/bin/bash

source "./utils/base-functions.sh"
source "./utils/enrollCAClient.sh"
source "./utils/enrollOrgUserTls.sh"
source "./utils/registerOrgUser.sh"

export $(grep -v '^#' ../.env | xargs)

export PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}


# if ! [ -d "${ROOT_CA_CLIENT_PATH}" ]; then
#    echo ""
#    textColor "ROOT CA Client is not Registered," 2
#    echo "Registering ROOT TLS CA Client with default credentials."

#    enrollCAClient ${ROOT_CA_CLIENT_PATH} ${ROOT_CA_ADMIN_NAME} ${ROOT_CA_ADMIN_PASSWORD} ${ROOT_CA_NAME} ${ROOT_CA_URL} ${ROOT_CA_ROOT_TLS_CERTFILES} ${ROOT_CA_CLIENT_PROFILE_FILE}

# else
#    echo ""
#    textColor "ROOT CA Client is already Registered," 1
#    echo ""
#    inputLog "ROOT_CA_CLIENT_PATH: ${ROOT_CA_CLIENT_PATH}"
#    echo ""
# fi

# export $(grep -v '^#' ../.env | xargs)
# # Register ca bootstrap user with root ca

# echo ""
# echo "Register CA's ${CA_ADMIN_NAME} user on Root TLS CA Server.. "
# echo ""

# ATTR='"hf.IntermediateCA=true"' # included for intermediate CA user only
# echo "registerOrgUser ${ROOT_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} client ${ROOT_CA_NAME} ${ROOT_CA_ROOT_TLS_CERTFILES} ${CA_ADMIN_ID_AFFILICATION} ${ATTR}"
# registerOrgUser ${ROOT_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} client ${ROOT_CA_NAME} ${ROOT_CA_ROOT_TLS_CERTFILES} ${CA_ADMIN_ID_AFFILICATION} ${ATTR}
# # fabric-ca-client identity list -u https://${ROOT_CA_URL} --tls.certfiles ${ROOT_CA_ROOT_TLS_CERTFILES}



 export $(grep -v '^#' ../.env | xargs)



if ! [ -d "${TLS_CA_CLIENT_PATH}" ]; then
   echo ""  
   textColor "TLS CA Client is not Registered," 2
   echo "Registering TLS CA Client with default credentials."
   echo ""
   enrollCAClient ${TLS_CA_CLIENT_PATH} ${TLS_CA_ADMIN_NAME} ${TLS_CA_ADMIN_PASSWORD} ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES} ${TLS_CA_CLIENT_PROFILE_FILE}
   
else
   echo ""
   textColor "TLS CA Client is already Registered," 1
   echo ""
   inputLog "CA_CLIENT_PATH: ${TLS_CA_CLIENT_PATH}"
   echo ""
fi

## Register Admin Users TLS Profile

export $(grep -v '^#' ../.env | xargs)

echo ""
echo "Register CA's ${CA_ADMIN_NAME} user on TLS CA Server.. "
echo ""

CA_ADMIN_TLS_MSP_DIR=${PROJECT_ROOT_PATH}/tlsca_ca

if [ -d "${CA_ADMIN_TLS_MSP_DIR}" ]; then
   echo ""  
   echo "User '${CA_ADMIN_NAME}' is Already registered and TLS MSP is available at"
   inputLog "User TLS MSP Path: ${CA_ADMIN_TLS_MSP_DIR}"
   echo ""

else
  
   ## Register Admin
   echo "registerOrgUser ${TLS_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} client ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${CA_ADMIN_ID_AFFILICATION}" 
   registerOrgUser ${TLS_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} client ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${CA_ADMIN_ID_AFFILICATION}

   ## Enroll Admin and Generate MSP profile 
   ##Need to check peer name is valid in the certificate CDN
   echo "enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} ${CA_NAME} ${CA_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}"
   enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} ca.vyapar.bcngame.in ${CA_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}
   echo ""
   echo "Generating Default certificate formats in TLS folder"
   echo ""
   cp "${CA_ADMIN_TLS_MSP_DIR}/tlscacerts/"* "${CA_ADMIN_TLS_MSP_DIR}/ca.crt"
   cp "${CA_ADMIN_TLS_MSP_DIR}/signcerts/"* "${CA_ADMIN_TLS_MSP_DIR}/server.crt"
   cp "${CA_ADMIN_TLS_MSP_DIR}/keystore/"* "${CA_ADMIN_TLS_MSP_DIR}/server.key"
fi

## Start CA Server
export $(grep -v '^#' ../.env | xargs)

printHeadline "Starting CA Server for 'Blockchain Netowrk'" "U1F913"

echo "Configuration"
inputLog "CA_NAME: ${CA_NAME}"
inputLog "FABRIC_CA_VERSION: ${FABRIC_CA_VERSION}"
inputLog "CA_SERVER_PORT: ${CA_SERVER_PORT}"
inputLog "CA_CRYPTO_PATH: ${CA_CRYPTO_PATH}"
inputLog "CA_SERVER_PROFILE_FILE: ${CA_SERVER_PROFILE_FILE}"
inputLog "DOCKER_FILE: ${PROJECT_DOCKER_FILE_PATH}/ca.yaml"
inputLog "DOCKER_NETWORK_NAME: ${DOCKER_NETWORK_NAME}"

inputLog "CA_ADMIN_NAME: ${CA_ADMIN_NAME}"
inputLog "CA_ADMIN_PASSWORD: ${CA_ADMIN_PASSWORD}"


rm -Rf ${CA_CRYPTO_PATH}
mkdir -p ${CA_CRYPTO_PATH}/users/${CA_ADMIN_NAME}@${CA_NAME}
mv ${PROJECT_ROOT_PATH}/tlsca_ca ${CA_CRYPTO_PATH}/users/${CA_ADMIN_NAME}@${CA_NAME}/tls
cp ${CA_CRYPTO_PATH}/users/${CA_ADMIN_NAME}@${CA_NAME}/tls/server.crt ${CA_CRYPTO_PATH}/${TLS_CA_NAME}-tls-cert.pem
cp ${CA_CRYPTO_PATH}/users/${CA_ADMIN_NAME}@${CA_NAME}/tls/server.key ${CA_CRYPTO_PATH}/${TLS_CA_NAME}.key
cp ${CA_SERVER_PROFILE_FILE} "${CA_CRYPTO_PATH}/fabric-ca-server-config.yaml"
sleep 3s
docker-compose -f ${PROJECT_DOCKER_FILE_PATH}/ca.yaml  up -d  #--scale ca=3
sleep 3s
# docker logs --tail 5 ${CA_NAME}
docker ps --filter "name=${CA_NAME}"

# docker stop ${CA_NAME}
# sleep 5s
# rm -Rf ${CA_CRYPTO_PATH}/*
# mkdir -p ${CA_CRYPTO_PATH}/users/${CA_ADMIN_USER_NAME}@${ORG_NAME}
# mv ${PROJECT_ROOT_PATH}/tlsca_ca ${CA_CRYPTO_PATH}/users/${CA_ADMIN_USER_NAME}@${ORG_NAME}/tls
# cp ${CA_CRYPTO_PATH}/users/${CA_ADMIN_USER_NAME}@${ORG_NAME}/tls/server.crt ${CA_CRYPTO_PATH}/ca.mhbcn.gov.in-tls-cert.pem
# cp ${CA_SERVER_PROFILE_FILE} "${CA_CRYPTO_PATH}/fabric-ca-server-config.yaml"
# sleep 5s
# docker start ${CA_NAME}


# ssh bepds@10.152.62.8 mkdir -p ${CA_CRYPTO_PATH}

# scp -r ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.8:${CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.7 mkdir -p ${CA_CRYPTO_PATH}

# scp -r ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.7:${CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.9  mkdir -p ${CA_CRYPTO_PATH}

# scp -r ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.9:${CA_ROOT_TLS_CERTFILES}

# ssh bepds@10.152.62.10  mkdir -p ${CA_CRYPTO_PATH}

# scp -r ${CA_ROOT_TLS_CERTFILES} bepds@10.152.62.10:${CA_ROOT_TLS_CERTFILES}


