#!/bin/bash

function registerOrgUser()
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
        echo "Err:-  User Name is missing.. exiting..."
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
        ORG_USER_TYPE=""
        echo "Err:- User type is missing.. exiting..."
        exit
    else
        ORG_USER_TYPE="$4"
    fi

    if [ -z "$5" ]; then
        CA_NAME=""
        echo "Err:- CA Name is missing.. exiting..."
        exit
    else
        CA_NAME="$5"
    fi

    if [ -z "$6" ]; then
        CA_ROOT_TLS_CERTFILES=""
        echo "Err:- CA ROOT TLS Certificate path is missing.. exiting..."
        exit
    else
        CA_ROOT_TLS_CERTFILES="$6"
    fi
    
    if [ -z "$7" ]; then
        ID_AFFILICATION=""
        echo "Err:- User ID_AFFILICATION is missing (eg. org1.department1).. exiting..."
        exit
    else
        ID_AFFILICATION="$7"
    fi

    if [ -z "$8" ]; then       
       ID_ATTR="No"    
    else
       ID_ATTR="$8"
    fi


    echo "----------------Start of Information -----------------"
    echo "Register Organization's user on CA Server.. "
    echo ""
    inputLog "ORG_USER_NAME: ${ORG_USER_NAME}"
    inputLog "ORG_USER_PASSWORD: ${ORG_USER_PASSWORD}"
    inputLog "ORG_USER_TYPE: ${ORG_USER_TYPE}"
     inputLog "ORG_USER_AFFILATION: ${ID_AFFILICATION}"
	
    inputLog "CA_NAME: ${CA_NAME}"
    inputLog "CA_ROOT_TLS_CERTFILES: ${CA_ROOT_TLS_CERTFILES}"
    inputLog "Attributes: ${ID_ATTR}"

    echo "---------------End of Information-----------------------"

    ## Register Admin on CA Server
    export FABRIC_CA_CLIENT_HOME=${CA_CLIENT_PATH}

    if [ $ID_ATTR == "No" ] || [ -z "${ID_ATTR}" ]
	then
        echo "Without ATTR -Normal User -> fabric-ca-client register --caname ${CA_NAME} --csr.cn ${ORG_USER_NAME} --id.name ${ORG_USER_NAME} --id.secret ${ORG_USER_PASSWORD} --id.type ${ORG_USER_TYPE} --id.affiliation ${ID_AFFILICATION} --tls.certfiles ${CA_ROOT_TLS_CERTFILES}"
	    fabric-ca-client register --caname ${CA_NAME} --id.name ${ORG_USER_NAME} --id.secret ${ORG_USER_PASSWORD} --id.type ${ORG_USER_TYPE} --tls.certfiles ${CA_ROOT_TLS_CERTFILES} --id.affiliation ${ID_AFFILICATION} 
    else
        echo "With ATTR - CA Users -> fabric-ca-client register --caname ${CA_NAME} --csr.cn ${ORG_USER_NAME} --id.name ${ORG_USER_NAME} --id.secret ${ORG_USER_PASSWORD} --id.type ${ORG_USER_TYPE} --id.affiliation ${ID_AFFILICATION} --tls.certfiles ${CA_ROOT_TLS_CERTFILES} --id.attrs ${ID_ATTR}"
	    fabric-ca-client register --caname ${CA_NAME} --csr.cn ${ORG_USER_NAME} --id.name ${ORG_USER_NAME} --id.secret ${ORG_USER_PASSWORD} --id.type ${ORG_USER_TYPE}  --tls.certfiles ${CA_ROOT_TLS_CERTFILES} --id.attrs ${ID_ATTR} --id.affiliation ${ID_AFFILICATION}
    fi

    echo ""
    inputLog "User registration completed successful.... "
    echo ""
}
