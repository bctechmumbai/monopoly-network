/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0edited
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');

const userName = 'courtClient';
// const userPass='fcsDepotClientpw';
const adminName = 'tlsca.mhbcn.gov.in';
//IIlBveOWdDKC
const orgMSP='COURTMSP';

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
        // const ccpPath = path.resolve(__dirname,'../BCN_CCP/courts/connection_peer1_court.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['tlsca.mhbcn.gov.in'].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        // const walletPath = path.join(process.cwd(), '..', 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userIdentity = await wallet.get(orgMSP+'_tls_'+userName);
        if (userIdentity) {
            console.log(`An identity for the user ${userName} already exists in the wallet`);
            return;
        }

        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.get(orgMSP+'_tls_'+adminName);
        if (!adminIdentity) {
            console.log(`An identity for the admin user ${adminName} does not exist in the wallet`);
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // build a user object for authenticating with the CA
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, adminName);

        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({
            affiliation: 'judicialchain.court',
            enrollmentID: userName,
            role: 'client'  // change role for admin if required
        }, adminUser);
        console.log(secret);
        const enrollment = await ca.enroll({
            enrollmentID: userName,
            enrollmentSecret: secret
        });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: orgMSP,
            type: 'X.509',
        };
        await wallet.put(orgMSP+'_tls_'+userName, x509Identity);
        console.log(`Successfully registered and enrolled client user ${userName} and imported it into the wallet`);

    } catch (error) {
        console.error(`Failed to register client user ${userName}: ${error}`);
        process.exit(1);
    }
}

main();
