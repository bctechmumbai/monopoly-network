/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

"use strict";

const FabricCAServices = require("fabric-ca-client");
const { Wallets } = require("fabric-network");
const fs = require("fs");
const path = require("path");
const { exit } = require("process");
require("dotenv").config();
const jwt = require("jsonwebtoken");
const config = process.env;

const ccpPath = path.resolve(__dirname, process.env.BCN_CONFIG_PATH);
const ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));
const walletPath = path.resolve(__dirname, process.env.BCN_WALLET_PATH);

let jsonResult;

class player {
  // Get player from local wallet from API Server data.
  async getPlayerFromWallet(userId) {
    // console.info(`Wallet path: ${walletPath}`);
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const userIdentity = await wallet.get(userId);
    if (userIdentity) {
      return userIdentity;
    } else return null;
  }

  async getPlayerFromBCN(userId) {
    ///TODO
    return null;
  }

  async getPlayer(userId) {
    let inWallet = null;
    try {
      // Check in wallet
      inWallet = await this.getPlayerFromWallet(userId);
    } catch (error) {
      console.error("Unable to read from wallet");
      console.error(error.message);
      process.exit(1);
    }
    if (inWallet !== null) {
      return inWallet;
    } else {
      // Check in BCN
      let inBCNCA = await this.getPlayerFromBCN(userId);
      return inBCNCA;
    }
  }

  async enrollPlayer(userName, userPass, ca, tls = false) {
    try {
      const identity = await this.getPlayer(userName);
      if (identity) {
        console.log(
          `An identity for the admin user ${userName} already exists in the wallet`
        );
        return {
          status: "Error",
          data: {
            errorCode: "AE-Already Exists-422",
            errorMessage: `User: ${userName} already exists in wallet`,
          },
        };
      }

      // Enroll the admin user, and import the new identity into the wallet.

      // Enroll Enroll the user
      // const ca = new FabricCAServices(
      //   caInfo.url,
      //   { trustedRoots: caTLSCACerts, verify: false },
      //   caInfo.caName
      // );

      const enrollment = await ca.enroll({
        enrollmentID: userName,
        enrollmentSecret: userPass,
      });

      //Import the new identity into the wallet.
      const orgMSP = "PLAYSTATIONONEMSP";
      const x509Identity = {
        credentials: {
          certificate: enrollment.certificate,
          privateKey: enrollment.key.toBytes(),
        },
        mspId: orgMSP,
        type: "X.509",
      };
      const wallet = await Wallets.newFileSystemWallet(walletPath);
      await wallet.put(userName, x509Identity);
      console.log(
        `Successfully enrolled user ${userName} and imported it into the wallet`
      );
      return {
        status: "Success",
        data: {
          userName: `${userName}`,
          message: `Successfully enrolled player user ${userName} and imported it into the wallet`,
        },
      };
    } catch (error) {
      console.error(`Failed to enroll user ${userName}: ${error}`);
      return {
        status: "Error",
        data: {
          errorCode: "AE-Unable-to-Process-422",
          errorMessage: `Unable to enroll user: ${userName} please try again`,
        },
      };
    }
  }

  async registerPlayer(req) {
    if (req.body == null || req.body.toString().trim() == "") {
      return {
        Status: "Error",
        data: { errorCode: "200", errorMessage: "Body parameter missing." },
      };
    }
    if (req.body.assetId == null || req.body.assetId == undefined) {
      return {
        Status: "Error",
        data: {
          errorCode: "200",
          errorMessage: "User  Email (assetId) required",
        },
      };
    }
    if (req.body.password == null || req.body.password == undefined) {
      return {
        Status: "Error",
        data: { errorCode: "200", errorMessage: "Password is required" },
      };
    }
    const token = req.headers["x-access-token"];

    if (!token) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-SYNTAX-400",
          errorMessage: "Missing request authentication token.",
        },
      };

      return jsonResult;
    }

    let adminName;
    let decodedToken = this.decodeToken(token);
    if (decodedToken.Status == "Success") {
      adminName = decodedToken.data.userName;
    } else {
      return decodedToken;
    }

    // try {
    const affiliation = "vyapar.playstationone";

    const role = "client";

    const userName = req.body.assetId;
    const userPass = req.body.password;

    // // Check to see if we've already enrolled the user.
    const userIdentity = await this.getPlayer(userName);

    if (userIdentity) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-USER_ALREADY_EXISTS-422",
          errorMessage: `An identity for the user ${userName} already exist in the wallet`,
        },
      };
      // console.error(jsonResult);
      return jsonResult;
    }

    // Check to see if we've already enrolled the admin user.
    const adminIdentity = await this.getPlayer(adminName);
    if (!adminIdentity) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-USER_NOT_EXISTS-422",
          errorMessage: `An identity for the admin user ${adminName} does not exist in the wallet`,
        },
      };
      console.error(jsonResult);
      return jsonResult;
    }

    // build a user object for authenticating with the CA
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    const provider = wallet
      .getProviderRegistry()
      .getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, adminName);

    const caName = "ca.vyapar.bcngame.in";
    const tlscaName = "tlsca.vyapar.bcngame.in";
    const caURL = ccp.certificateAuthorities[caName].url;
    const tlscaURL = ccp.certificateAuthorities[tlscaName].url;
    const tlsca = new FabricCAServices(tlscaURL);

    const ca = new FabricCAServices(caURL);
    try {
      const secret = await ca.register(
        {
          affiliation: affiliation,
          enrollmentID: userName,
          enrollmentSecret: userPass,
          role: role,
          maxEnrollments: 100,
        },
        adminUser
      );
    } catch (error) {
      console.error(error.errors[0].code);

      if (error.errors[0].code == 74) {
        return await this.enrollPlayer(userName, userPass, ca);
      } else if (error.errors[0].code == 71) {
        console.error(`Unable to enroll user ${error}`);
        jsonResult = {
          status: "Error",
          data: {
            errorCode: "AE-ERROR-USER-AUTHENTICATION-FAIL-422",
            errorMessage:"You are not authorized to register other users. Please check your token...!",
          },
        };
        return jsonResult;
      } else {
        throw error;
      }
    }
    try {
      return await this.enrollPlayer(userName, userPass, ca);
    } catch (e) {
      console.error(`Unable to enroll user ${e}`);
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-ERROR-USER-ENROLL-422",
          errorMessage: error.message,
        },
      };
      return jsonResult;
    }

    // const tlssecret = await tlsca.register(
    //   {
    //     affiliation: affiliation,
    //     enrollmentID: userName,
    //     enrollmentSecret: userPass,
    //     role: role,
    //     maxEnrollments: 100,
    //   },
    //   adminUser
    // );

    //Enroll User to import the identity in wallet
    //  usertlswalletstatus= await this.enrollPlayer(userName, userPass, ca, tls=true );

    // } catch (error) {
    //   jsonResult = {
    //     status: "Error",
    //     data: {
    //       errorCode: "AE-ERROR-422",
    //       errorMessage: error.message,
    //     },
    //   };
    //   console.error(jsonResult);
    //   return jsonResult;
    //   //  process.exit(1);
    // }
  }

  async getToken(req) {
    if (req.body == null || req.body.toString().trim() == "") {
      return {
        Status: "Error",
        data: { errorCode: "200", errorMessage: "Body parameter missing." },
      };
    }
    if (req.body.assetId == null || req.body.assetId == undefined) {
      return {
        Status: "Error",
        data: {
          errorCode: "200",
          errorMessage: "User  Email (assetId) required",
        },
      };
    }
    if (req.body.password == null || req.body.password == undefined) {
      return {
        Status: "Error",
        data: { errorCode: "200", errorMessage: "Password is required" },
      };
    }
    const userName = req.body.assetId;
    const userPass = req.body.password;

    let user = await this.getPlayer(userName);
    if (user != null) {
      const token = jwt.sign(
        { userName: userName, userData: user },
        process.env.TOKEN_KEY,
        { expiresIn: "1000d" }
      );
      return {
        Status: "Success",
        data:{"token":token }
      };
    } else {
      return {
        Status: "Error",
        data: {
          errorCode: "404",
          errorMessage: `Invalid credentials or User ${userName} is not registered on BCN`,
        },
      };
    }
  }

  decodeToken(token) {
    if (!token) {
      return {
        Status: "Error",
        data: {
          errorCode: "403",
          errorMessage: "A token is required for authentication",
        },
      };
    }
    try {
      const decoded = jwt.verify(token, config.TOKEN_KEY);
      return {
        Status: "Success",
        data: decoded,
      };
    } catch (error) {
      return {
        Status: "Error",
        data: {
          errorCode: "400",
          errorMessage: error.message,
        },
      };
    }
  }

  async verifyToken(token) {
    ///TODO
  }
}
module.exports = player;
// main();
