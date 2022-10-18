/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { exit } = require('process');

// const adminName = 'ca.mhbcn.gov.in';
const adminName = 'playstationoneAdmin';
// const adminPass='caadminpw';
const adminPass='playstationoneAdminpw';
const orgMSP='PLAYSTATIONONEMSP';
const caName = 'ca.vyapar.bcngame.in'

require("dotenv").config();

const ccpPath = path.resolve(
  __dirname,
  process.env.BCN_CONFIG_PATH  
);

const walletPath=path.resolve(
    __dirname,
    process.env.BCN_WALLET_PATH  
  );

async function main() {
    try {
        
        // load the network configuration
        // const ccpPath = path.resolve(__dirname, '../BCN_CCP/courts/connection_peer1_court.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
       
        // Create a new CA client for interacting with the CA.
        const caInfo = ccp.certificateAuthorities[caName];
        
        const caTLSCACerts = caInfo.tlsCACerts.pem;
        
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);
         
        // Create a new file system based wallet for managing identities.
        // const walletPath = path.join(process.env.BCN_WALLET_PATH);
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identity = await wallet.get(orgMSP+"_"+adminName);
        if (identity) {
            console.log(`An identity for the admin user ${adminName} already exists in the wallet`);
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll({ enrollmentID: adminName, enrollmentSecret: adminPass });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: orgMSP,
            type: 'X.509',
        };
        await wallet.put(orgMSP+"_"+adminName, x509Identity);
        console.log(`Successfully enrolled admin user ${adminName} and imported it into the wallet`);

    } catch (error) {
        console.error(`Failed to enroll admin user ${adminName}: ${error}`);
        process.exit(1);
    }
}

main();
