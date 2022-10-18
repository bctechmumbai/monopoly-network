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
   echo "Err:- Orderer Organization name is missing.. exiting..."
   exit
else
   ORG_NAME="$1"
fi

if [ -z "$2" ]; then
   ORG_NAME_SHORT=""
   echo "Err:- Orderer Organization short name is missing.. exiting..."
   exit
else
   ORG_NAME_SHORT="$2"
fi

if [ -z "$3" ]; then
   ORDERER_NO=""
   echo "Err:- Orderer Name is missing.. exiting..."
   exit
else
   ORDERER_NO="$3"
fi

ORG_CRYPTO_PATH=${PROJECT_CRYPTO_PATH}/ordererOrganizations/${ORG_NAME}

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
   echo ""
   enrollCAClient ${CA_CLIENT_PATH} ${CA_ADMIN_NAME} ${CA_ADMIN_PASSWORD} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES} ${CA_CLIENT_PROFILE_FILE}
   
else
   echo ""
   echo "CA Client is already Registered,"
   echo ""
   inputLog "CA_CLIENT_PATH: ${CA_CLIENT_PATH}"
   echo ""
fi



## Register Admin on CA Server

ORG_ADMIN_USER_NAME=${ORG_NAME_SHORT}Admind
ORG_ADMIN_USER_PASSWORD=${ORG_NAME_SHORT}Adminpw
ORG_ADMIN_MSP_DIR=${ORG_CRYPTO_PATH}/users/${ORG_ADMIN_USER_NAME}@${ORG_NAME}/msp
ORG_ADMIN_TLS_MSP_DIR=${ORG_CRYPTO_PATH}/users/${ORG_ADMIN_USER_NAME}@${ORG_NAME}/tls
ORG_HF_ATTR='"hf.Registrar.Roles=orderer,client",hf.Revoker=true'

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
   #7th parameter is for affilication
   #8th parameter is for roles of admin.
   echo "registerOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}"
   registerOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT} ${ORG_HF_ATTR} 

   ## Enroll Admin and Generate MSP profile 
   echo "enrollOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_ADMIN_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}"
   enrollOrgUser ${CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_ADMIN_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}

   sleep 1s

   cp ${CRYPTO_MSP_CONFIG_FILE} "${ORG_ADMIN_MSP_DIR}/config.yaml"

fi



## Register Orderer on CA Server

ORDERER_NAME=${ORDERER_NO}.${ORG_NAME}
ORDERER_USER_NAME=${ORDERER_NAME}
ORDERER_USER_PASSWORD=${ORG_NAME_SHORT}${ORDERER_NO}pw
ORDERER_MSP_DIR=${ORG_CRYPTO_PATH}/orderers/${ORDERER_NAME}/msp
ORDERER_TLS_MSP_DIR=${ORG_CRYPTO_PATH}/orderers/${ORDERER_NAME}/tls

if [ -d "${ORDERER_MSP_DIR}" ]; then
   echo ""  
   echo "User '${ORDERER_USER_NAME}' is Already registered and MSP is available at"
   inputLog "User MSP Path: ${ORDERER_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Orderer user on CA Server.. "
   echo ""

   ## Register Orderer 
   echo "registerOrgUser ${CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} orderer ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}.orderers"
   registerOrgUser ${CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} orderer ${CA_NAME} ${CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}.orderers #7th parameter is for affilication

   ## Enroll Orderer and Generate MSP profile 
   echo "enrollOrgUser ${CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} ${ORDERER_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}"
   enrollOrgUser ${CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} ${ORDERER_MSP_DIR} ${CA_NAME} ${CA_URL} ${CA_ROOT_TLS_CERTFILES}

   sleep 1s

   cp ${CRYPTO_MSP_CONFIG_FILE} "${ORDERER_MSP_DIR}/config.yaml"
   
   ## Admin User certificate to Orderer MSP
   # mkdir -p ${ORDERER_MSP_DIR}/admincerts
   # cp ${ORG_ADMIN_MSP_DIR}/signcerts/cert.pem ${ORDERER_MSP_DIR}/admincerts/cert.pem
fi

## Create Organizations GLOBAL MSP if not available

if ! [ -d "${ORG_CRYPTO_PATH}/msp" ]; then

   echo ""
   echo "Generate Organization's Global MSP Directory... "
   echo ""

   # mkdir -p ${ORG_CRYPTO_PATH}/msp
   # cp -R "${ORDERER_MSP_DIR}/admincerts" "${ORG_CRYPTO_PATH}/msp/"
   # cp -R "${ORDERER_MSP_DIR}/cacerts" "${ORG_CRYPTO_PATH}/msp/"

   mkdir -p "${ORG_CRYPTO_PATH}/msp/admincerts"
   cp "${ORG_ADMIN_MSP_DIR}/signcerts/cert.pem" "${ORG_CRYPTO_PATH}/msp/admincerts/cert.pem"
   cp -R "${ORDERER_MSP_DIR}/cacerts" "${ORG_CRYPTO_PATH}/msp/"
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
   registerOrgUser ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} admin ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT} #7th parameter is for affilication

   ## Enroll Admin and Generate MSP profile 
   ##Need to check orderer name is valid in the certificate CDN
   echo "enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORG_NAME} ${ORG_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}"
   enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORG_ADMIN_USER_NAME} ${ORG_ADMIN_USER_PASSWORD} ${ORDERER_NAME} ${ORG_ADMIN_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}
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
  
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlscacerts" "${ORG_CRYPTO_PATH}/msp/"
   cp -R "${ORG_ADMIN_TLS_MSP_DIR}/tlsintermediatecerts" "${ORG_CRYPTO_PATH}/msp/"
fi    


## Register Users TLS Profile

echo ""
echo "Register Organization's ${ORDERER_USER_NAME} user on TLS CA Server.. "
echo ""


if [ -d "${ORDERER_TLS_MSP_DIR}" ]; then
   echo ""  
   echo "User '${ORDERER_USER_NAME}' is Already registered and TLS MSP is available at"
   inputLog "User TLS MSP Path: ${ORDERER_TLS_MSP_DIR}"
   echo ""

else
  
   echo ""
   echo "Register Organization's Orderer user on TLS CA Server.. "
   echo ""

   ## Register Orderer 
   echo "registerOrgUser ${TLS_CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} orderer ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}.orderers"
   registerOrgUser ${TLS_CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} orderer ${TLS_CA_NAME} ${TLS_CA_ROOT_TLS_CERTFILES} ${ORG_NAME_SHORT}.orderers #7th parameter is for affilication

   ## Enroll Orderer and Generate MSP profile 
   echo "enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} ${ORDERER_NAME} ${ORDERER_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}"
   enrollOrgUserTls ${TLS_CA_CLIENT_PATH} ${ORDERER_USER_NAME} ${ORDERER_USER_PASSWORD} ${ORDERER_NAME} ${ORDERER_TLS_MSP_DIR}  ${TLS_CA_NAME} ${TLS_CA_URL} ${TLS_CA_ROOT_TLS_CERTFILES}
 
   cp "${ORDERER_TLS_MSP_DIR}/tlscacerts/"* "${ORDERER_TLS_MSP_DIR}/ca.crt"
   cp "${ORDERER_TLS_MSP_DIR}/tlsintermediatecerts/"* "${ORDERER_TLS_MSP_DIR}/ica.crt"
   cp "${ORDERER_TLS_MSP_DIR}/signcerts/"* "${ORDERER_TLS_MSP_DIR}/server.crt"
   cp "${ORDERER_TLS_MSP_DIR}/keystore/"* "${ORDERER_TLS_MSP_DIR}/server.key"

   ## Add tlscacerts to Orderer's MSP directory
   cp -R "${ORDERER_TLS_MSP_DIR}/tlscacerts" "${ORDERER_MSP_DIR}/"
   cp -R "${ORDERER_TLS_MSP_DIR}/tlsintermediatecerts" "${ORDERER_MSP_DIR}/"
   
  
   ## Add tlscacerts to Organizations Global MSP directory
   # cp -R "${ORDERER_TLS_MSP_DIR}/tlscacerts" "${ORG_CRYPTO_PATH}/msp/"
fi    
   