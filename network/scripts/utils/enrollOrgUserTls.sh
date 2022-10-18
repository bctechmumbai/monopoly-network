#!/bin/bash

#source "./base-functions.sh"

function enrollOrgUserTls()
{
    if [ -z "$1" ]; then
        CA_CLIENT_PATH=""
        echo "Err:- CA CLIENT Path is missing.. exiting..."
        exit
    else
        CA_CLIENT_PATH="$1"
    fi

    if [ -z "$2" ]; then
        ORG_USER_NAME=""
        echo "Err:- User Name is missing.. exiting..."
        exit
    else
        ORG_USER_NAME="$2"
    fi

    if [ -z "$3" ]; then
        ORG_USER_PASSWORD=""
        echo "Err:- User password is missing.. exiting..."
        exit
    else
        ORG_USER_PASSWORD="$3"
    fi

     if [ -z "$4" ]; then
        PEER_NAME=""
        echo "Err:- PEER Name is missing.. exiting..."
        exit
    else
        PEER_NAME="$4"
    fi

    if [ -z "$5" ]; then
        ORG_USER_MSP_DIR=""
        echo "Err:- User MSP Directory path is missing.. exiting..."
        exit
    else
        ORG_USER_MSP_DIR="$5"
    fi

    if [ -z "$6" ]; then
        CA_NAME=""
        echo "Err:- CA Name is missing.. exiting..."
        exit
    else
        CA_NAME="$6"
    fi

    if [ -z "$7" ]; then
        CA_URL=""
        echo "Err:- CA URL is missing.. exiting..."
        exit
    else
        CA_URL="$7"
    fi


    if [ -z "$8" ]; then
        CA_ROOT_TLS_CERTFILES=""
        echo "Err:- CA ROOT TLS Certificate path is missing.. exiting..."
        exit
    else
        CA_ROOT_TLS_CERTFILES="$8"
    fi

    echo ""
    echo "Enroll Organization's '${ORG_USER_NAME}' user on CA Server.. "
    echo ""
    inputLog "ORG_USER_NAME: ${ORG_USER_NAME}"
    inputLog "ORG_USER_PASSWORD: ${ORG_USER_PASSWORD}"
    inputLog "ORG_USER_MSP_DIRECTORY: ${ORG_USER_MSP_DIR}"
    inputLog "PEER_NAME: ${PEER_NAME}"

    inputLog "CA_NAME: ${CA_NAME}"
    inputLog "CA_CLIENT_PATH: ${CA_CLIENT_PATH}"
    inputLog "CA_ROOT_TLS_CERTFILES: ${CA_ROOT_TLS_CERTFILES}"
    echo ""

    ## Enroll Admin on CA Server
    export FABRIC_CA_CLIENT_HOME=${CA_CLIENT_PATH}

    fabric-ca-client enroll -u https://${ORG_USER_NAME}:${ORG_USER_PASSWORD}@${CA_URL} --caname ${CA_NAME} -M ${ORG_USER_MSP_DIR} --tls.certfiles ${CA_ROOT_TLS_CERTFILES} --enrollment.profile tls --csr.hosts ${PEER_NAME} --csr.hosts ${CA_NAME}

    echo ""
    inputLog "User Enrollment successfully completed .... " 
    echo ""

}
