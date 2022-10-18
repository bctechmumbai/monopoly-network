#!/bin/bash

# source "/blockchain_network/Network/scripts/utils/base-functions.sh"

function enrollCAClient()
{
    if [ -z "$1" ]; then
        CA_CLIENT_PATH=""
        echo "Err:- CA CLIENT PATH is missing.. exiting..."
        exit
    else
        CA_CLIENT_PATH="$1"
    fi

    if [ -z "$2" ]; then
        CA_ADMIN_NAME=""
        echo "Err:- CA Admin Name is missing.. exiting..."
        exit
    else
        CA_ADMIN_NAME="$2"
    fi

    if [ -z "$3" ]; then
        CA_ADMIN_PASSWORD=""
        echo "Err:- CA Admin password is missing.. exiting..."
        exit
    else
        CA_ADMIN_PASSWORD="$3"
    fi

    if [ -z "$4" ]; then
        CA_NAME=""
        echo "Err:- CA Name is missing.. exiting..."
        exit
    else
        CA_NAME="$4"
    fi

    if [ -z "$5" ]; then
        CA_URL=""
        echo "Err:- CA Address (URL) is missing.. exiting..."
        exit
    else
        CA_URL="$5"
    fi

    if [ -z "$6" ]; then
        CA_ROOT_TLS_CERTFILES=""
        echo "Err:- CA ROOT TLS Certificate path is missing.. exiting..."
        exit
    else
        CA_ROOT_TLS_CERTFILES="$6"
    fi

        if [ -z "$7" ]; then
        CA_CLIENT_PROFILE_FILE=""
        echo "Err:- CA Client profile file is missing.. exiting..."
        exit
    else
        CA_CLIENT_PROFILE_FILE="$7"
    fi

    export FABRIC_CA_CLIENT_HOME=${CA_CLIENT_PATH}
   
    mkdir -p ${FABRIC_CA_CLIENT_HOME}
    
    cp ${CA_CLIENT_PROFILE_FILE} "${FABRIC_CA_CLIENT_HOME}/fabric-ca-client-config.yaml"
    
    ## CA Server Client Registration

    echo ""
    echo "Enrolling CA Client with following Configuration:"
  
    inputLog "CA_CLIENT_PATH: ${FABRIC_CA_CLIENT_HOME}"
    inputLog "CA_NAME: ${CA_NAME}"
    inputLog "CA_URL: ${CA_URL}"
    inputLog "CA_ADMIN_NAME: ${CA_ADMIN_NAME}"
    inputLog "CA_ADMIN_PASSWORD: ${CA_ADMIN_PASSWORD}"
    inputLog "CA_ROOT_TLS_CERTFILES: ${CA_ROOT_TLS_CERTFILES}"
    inputLog "CA_CLIENT_PROFILE_FILE: ${CA_CLIENT_PROFILE_FILE}"
    
    echo ""
    sleep 2s
    echo "fabric-ca-client enroll -u https://${CA_ADMIN_NAME}:${CA_ADMIN_PASSWORD}@${CA_URL} --caname ${CA_NAME} --tls.certfiles ${CA_ROOT_TLS_CERTFILES}"
    fabric-ca-client enroll -u https://${CA_ADMIN_NAME}:${CA_ADMIN_PASSWORD}@${CA_URL} --caname ${CA_NAME} --tls.certfiles ${CA_ROOT_TLS_CERTFILES}

    #enrollCAClient ${ROOT_CA_CLIENT_PATH} ${ROOT_CA_ADMIN_NAME} ${ROOT_CA_ADMIN_PASSWORD} ${ROOT_CA_NAME} ${ROOT_CA_URL} ${ROOT_CA_ROOT_TLS_CERTFILES} ${ROOT_CA_CLIENT_PROFILE_FILE}
    echo ""
    inputLog "CA Client Enrollment successful.... " 
    echo ""
}