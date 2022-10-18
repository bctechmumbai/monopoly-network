#!/bin/bash

export $(grep -v '^#' ../.env | xargs)

source "./utils/base-functions.sh"
source "./utils/enrollCAClient.sh"
source "./utils/registerOrgUser.sh"
source "./utils/enrollOrgUser.sh"
source "./utils/enrollOrgUserTls.sh"


PATH=${PROJECT_NETWORK_PATH}/bin:${PATH}


if [ -z "$1" ]; then
   ORG_NAME=""
   echo "Err:- Peer Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi

if [ -z "$2" ]; then
   ORG_NAME_SHORT=""
   echo "Err:- Peer Organization short name is missing.. exiting..."
   exit
else
   ORG_NAME_SHORT="$2"
fi

if [ -z "$3" ]; then
   PEER_NO=""
   echo "Err:- Peer Name is missing.. exiting..."
   exit
else
   PEER_NO="$3"
fi

ORG_CRYPTO_PATH=${PROJECT_CRYPTO_PATH}/peerOrganizations/${ORG_NAME}

printHeadline "Registering Organization and Org Admin on 'Blockchain Netowrk'" "U1F913"

echo "Configuration"
echo ""
inputLog "ORG_NAME: ${ORG_NAME}"
inputLog "ORG_NAME_SHORT: ${ORG_NAME_SHORT}"
inputLog "ORG_CRYPTO_PATH: ${ORG_CRYPTO_PATH}"
echo ""

sleep 2s

# if CA client is not registered, register first

if ! [ -d "${CA_CLIENT_PATH}" ]; then
   echo ""  
   echo "CA Client is not Registered,"
   echo "Registering CA Client with default credentials."
   echo "enrollCAClient ${CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES} ${CA_CLIENT_PROFILE_FILE}"
   enrollCAClient ${CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES} ${CA_CLIENT_PROFILE_FILE}
   
else
   echo ""
   echo "CA Client is already Registered,"
   echo ""
   inputLog "CA_CLIENT_PATH: ${CA_CLIENT_PATH}"
   echo ""
fi



## Register Admin on CA Server

ORG_ADMIN_USER_NAME=${ORG_NAME_SHORT}Admin
ORG_ADMIN_USER_PASSWORD=${ORG_NAME_SHORT}Adminpw
ORG_ADMIN_MSP_DIR=${ORG_CRYPTO_PATH}/users/${ORG_ADMIN_USER_NAME}@${ORG_NAME}/msp
ORG_ADMIN_TLS_MSP_DIR=${ORG_CRYPTO_PATH}/users/${ORG_ADMIN_USER_NAME}@${ORG_NAME}/tls
ORG_ADMIN_AFFLILIATION=${BCN_NAME}.${ORG_NAME_SHORT}
ORG_HF_ATTR='"hf.Registrar.Roles=peer,client",hf.Revoker=true' 

if [ -d "${ORG_ADMIN_MSP_DIR}" ]; then
   echo ""  
   echo "User '${ORG_ADMIN_USER_NAME}' is Already registered and MSP is available at"
   inputLog "User MSP Path: ${ORG_ADMIN_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Admin user on CA Server.. "
   echo ""

   ## Register Admin 
   # 7th parameter is for affiliation
   # 8th parameter is for additing roles
   echo "${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}"
   registerOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_ADMIN_AFFLILIATION} ${ORG_HF_ATTR} 
   

   ## Enroll Admin and Generate MSP profile 
   echo "enrollOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_ADMIN_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}"
   enrollOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_ADMIN_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}

   sleep 1s

   cp ${CRYPTO_MSP_CONFIG_FILE} "${ORG_ADMIN_MSP_DIR}/config.yaml"
   
fi



## Register Peer on CA Server
 
PEER_NAME=${PEER_NO}.${ORG_NAME}
PEER_USER_NAME=${PEER_NAME}
PEER_USER_PASSWORD=${ORG_NAME_SHORT}${PEER_NO}pw
PEER_MSP_DIR=${ORG_CRYPTO_PATH}/peers/${PEER_NAME}/msp
PEER_TLS_MSP_DIR=${ORG_CRYPTO_PATH}/peers/${PEER_NAME}/tls
PEER_USER_AFFLILIATION=${BCN_NAME}.${ORG_NAME_SHORT}

if [ -d "${PEER_MSP_DIR}" ]; then
   echo ""  
   echo "User '${PEER_USER_NAME}' is Already registered and MSP is available at"
   inputLog "User MSP Path: ${PEER_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Peer user on CA Server.. "
   echo ""

   ## Register Peer 
   echo "registerOrgUser ${CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} peer ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}"
   registerOrgUser ${CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} peer ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${PEER_USER_AFFLILIATION} # 7th parameter is for affiliation

   ## Enroll Peer and Generate MSP profile 
   echo "enrollOrgUser ${CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} ${PEER_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}"
   enrollOrgUser ${CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} ${PEER_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}

   sleep 1s

   cp ${CRYPTO_MSP_CONFIG_FILE} "${PEER_MSP_DIR}/config.yaml"
   
   ## Admin User certificate to Peer MSP
   # mkdir -p ${PEER_MSP_DIR}/admincerts
   # cp ${ORG_ADMIN_MSP_DIR}/signcerts/cert.pem ${PEER_MSP_DIR}/admincerts/cert.pem
fi

## Create Organizations GLOBAL MSP if not available

if ! [ -d "${ORG_CRYPTO_PATH}/msp" ]; then

   echo ""
   echo "Generate Organization's Global MSP Directory... "
   echo ""

   # mkdir -p "${ORG_CRYPTO_PATH}/msp"
 
   mkdir -p "${ORG_CRYPTO_PATH}/msp/admincerts"
   cp "${ORG_ADMIN_MSP_DIR}/signcerts/cert.pem" "${ORG_CRYPTO_PATH}/msp/admincerts/cert.pem"
   cp -R "${PEER_MSP_DIR}/cacerts" "${ORG_CRYPTO_PATH}/msp/"
   cp -R "${PEER_MSP_DIR}/intermediatecerts" "${ORG_CRYPTO_PATH}/msp/"
   cp "${CRYPTO_MSP_CONFIG_FILE}" "${ORG_CRYPTO_PATH}/msp/config.yaml"
else
   echo ""
   echo "Organization's Global MSP Directory is Already Created ... "
   inputLog "Organization MSP Path: ${ORG_CRYPTO_PATH}/msp"
   echo ""
fi




# if TLS CA client is not registered, register first

if ! [ -d "${TLS_CA_CLIENT_PATH}" ]; then
   echo ""  
   echo "TLS CA Client is not Registered,"
   echo "Registering TLS CA Client with default credentials."
   echo ""
   enrollCAClient ${TLS_CA_CLIENT_PATH} ${TLS_CA_ADMIN_NAME} ${TLS_CA_ADMIN_PASSWORD} ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES} ${TLS_CA_CLIENT_PROFILE_FILE}
   
else
   echo ""
   echo "TLS CA Client is already Registered,"
   echo ""
   inputLog "CA_CLIENT_PATH: ${TLS_CA_CLIENT_PATH}"
   echo ""
fi

## Register Admin Users TLS Profile

echo ""
echo "Register Organization's ${ORG_ADMIN_USER_NAME} user on TLS CA Server.. "
echo ""


if [ -d "${ORG_ADMIN_TLS_MSP_DIR}" ]; then
   echo ""  
   echo "User '${ORG_ADMIN_USER_NAME}' is Already registered and TLS MSP is available at"
   inputLog "User TLS MSP Path: ${ORG_ADMIN_TLS_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Admin user on TLS CA Server.. "
   echo ""

   ## Register Admin
   echo "registerOrgUser ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}" 
   registerOrgUser ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_ADMIN_AFFLILIATION} # 7th parameter is for affiliation

   ## Enroll Admin and Generate MSP profile 
   ##Need to check peer name is valid in the certificate CDN
   echo "enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_NAME} ${ORG_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}"
   enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${PEER_NAME} ${ORG_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}
   echo ""
   echo "Generating Default certificate formats in TLS folder"
   echo ""
   cp "${ORG_ADMIN_TLS_MSP_DIR}/tlscacerts/"* "${ORG_ADMIN_TLS_MSP_DIR}/ca.crt"
   cp "${ORG_ADMIN_TLS_MSP_DIR}/tlsintermediatecerts/"* "${ORG_ADMIN_TLS_MSP_DIR}/ica.crt"
   cp "${ORG_ADMIN_TLS_MSP_DIR}/signcerts/"* "${ORG_ADMIN_TLS_MSP_DIR}/server.crt"
   cp "${ORG_ADMIN_TLS_MSP_DIR}/keystore/"* "${ORG_ADMIN_TLS_MSP_DIR}/server.key"

   ## Add tlscacerts to Admin's MSP directory
   echo ""
   echo "Copy tlscacerts to MSP directory from TLS directory"
   echo ""
   
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlscacerts" "${ORG_ADMIN_MSP_DIR}"
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlsintermediatecerts" "${ORG_ADMIN_MSP_DIR}"
  
   ## Add tlscacerts to Organizations Global MSP directory
   echo ""
   echo "Add tlscacerts to Organizations Global MSP directory"
   echo ""
   
   mkdir -p "${ORG_CRYPTO_PATH}/msp/"
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlscacerts" "${ORG_CRYPTO_PATH}/msp/"
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlsintermediatecerts" "${ORG_CRYPTO_PATH}/msp/"


 

fi    


## Register Users TLS Profile

echo ""
echo "Register Organization's ${PEER_USER_NAME} user on TLS CA Server.. "
echo ""


if [ -d "${PEER_TLS_MSP_DIR}" ]; then
   echo ""  
   echo "User '${PEER_USER_NAME}' is Already registered and TLS MSP is available at"
   inputLog "User TLS MSP Path: ${PEER_TLS_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Peer user on TLS CA Server.. "
   echo ""

   ## Register Peer 
   echo "registerOrgUser ${TLS_CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} peer ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}"
   registerOrgUser ${TLS_CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} peer ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${PEER_USER_AFFLILIATION} # 7th parameter is for affiliation

   ## Enroll Peer and Generate MSP profile 
   echo "enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} ${PEER_NAME} ${PEER_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}"
   enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${PEER_USER_NAME} ${PEER_USER_PASSWORD} ${PEER_NAME} ${PEER_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}
 
   cp "${PEER_TLS_MSP_DIR}/tlscacerts/"* "${PEER_TLS_MSP_DIR}/ca.crt"
   cp "${PEER_TLS_MSP_DIR}/tlsintermediatecerts/"* "${PEER_TLS_MSP_DIR}/ica.crt"
   cp "${PEER_TLS_MSP_DIR}/signcerts/"* "${PEER_TLS_MSP_DIR}/server.crt"
   cp "${PEER_TLS_MSP_DIR}/keystore/"* "${PEER_TLS_MSP_DIR}/server.key"

   ## Add tlscacerts to PEER's MSP directory
   cp -R "${PEER_TLS_MSP_DIR}/tlscacerts" "${PEER_MSP_DIR}/"
   cp -R "${PEER_TLS_MSP_DIR}/tlsintermediatecerts" "${PEER_MSP_DIR}/"
  
   ## Add tlscacerts to Organizations Global MSP directory
   # cp -R "${PEER_TLS_MSP_DIR}/tlscacerts" "${ORG_CRYPTO_PATH}/msp/"
fi    
   