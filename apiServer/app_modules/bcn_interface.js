// Setting for Hyperledger Fabric
// const jwt = require("jsonwebtoken");
// const { Wallets, Gateway } = require("fabric-network");
const {
  Wallets,
  FileSystemWallet,
  Gateway,
  DefaultEventHandlerStrategies,
  DefaultQueryHandlerStrategies,
} = require("fabric-network");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const ccpPath = path.resolve(__dirname, process.env.BCN_CONFIG_PATH);
const ccp = JSON.parse(fs.readFileSync(ccpPath, "utf8"));
// const tlsbcuser = "tls_playstationoneAdmin";

var jsonResult;
var gateway;

class bcn_interface {
  async connect_gateway(bcuser) {
   
      var gateway = new Gateway();
      const walletPath = path.resolve(__dirname, process.env.BCN_WALLET_PATH); // path.resolve(__dirname, "..", "wallet");
      // const walletPath = "../../asset-transfer-basic/application-javascript/wallet"
      const wallet = await Wallets.newFileSystemWallet(walletPath);
      if (!wallet) {
        jsonResult = {
          status: "Error",
          data: {
            errorCode: "AE-WALL_NOT_EXISTS-422",
            errorMessage:
            `Wallet ${walletPath} does not exist`,
          },
        };
        console.error(jsonResult);
        return jsonResult        
      }
      // console.debug(`Wallet path: ${walletPath}`);

      // Check to see if we've already enrolled the user.
      const userExists = await wallet.get(bcuser);
      if (!userExists) {
        jsonResult = {
          status: "Error",
          data: {
            errorCode: "AE-USER_NOT_EXISTS-422",
            errorMessage:
            `An identity for the user ${bcuser} does not exist in the wallet`,
          },
        };
        console.error(jsonResult);
        return jsonResult
      }
      // console.debug(`user ${bcuser} found in wallet path`);
      // console.log("---------------------------------------------");

      // console.log(wallet);
      // console.log(`bcuser: ${bcuser}`);
      // let inmemwallet=new X509WalletMixin();
      // let identity=inmemwallet.createIdentity("PLAYSTATIONONE","-----BEGIN CERTIFICATE-----\nMIICsDCCAlagAwIBAgIUeiec7orDEjIoY7a4wgaphUzUPacwCgYIKoZIzj0EAwIw\ngYkxCzAJBgNVBAYTAklOMRMwEQYDVQQIEwpNQUhBUkFTSFJBMQ8wDQYDVQQHEwZN\nVU1CQUkxGDAWBgNVBAoTD0JDTiBERU1PIFZZQVBBUjEfMB0GA1UECxMWQ0EtQmxv\nY2tDaGFpbiBQcm9qZWN0czEZMBcGA1UEAxMQZmFicmljLWNhLXNlcnZlcjAeFw0y\nMjA2MTAwNjI3MDBaFw0zNzA2MDYwNjI3MDBaME0xNTANBgNVBAsTBmNsaWVudDAN\nBgNVBAsTBnZ5YXBhcjAVBgNVBAsTDnBsYXlzdGF0aW9ub25lMRQwEgYDVQQDDAtu\nZXc4QG5pYy5pbjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCvitELobnxtoaey\n9KBCFVylXFy33+mlxjoleI1EqtQrpNRMWaNmeFqC1V2xnSuOH8/UUFl5pJMyfGzg\nU+ssNQejgdYwgdMwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwHQYDVR0O\nBBYEFHdBjlw19AVkGQ8D/WKouGtOIsoEMB8GA1UdIwQYMBaAFEvRDAW+l/LNRx/N\naSieZJg+XNuJMHMGCCoDBAUGBwgBBGd7ImF0dHJzIjp7ImhmLkFmZmlsaWF0aW9u\nIjoidnlhcGFyLnBsYXlzdGF0aW9ub25lIiwiaGYuRW5yb2xsbWVudElEIjoibmV3\nOEBuaWMuaW4iLCJoZi5UeXBlIjoiY2xpZW50In19MAoGCCqGSM49BAMCA0gAMEUC\nIQDIRsyVk4xtY8jjMhnei+sIMfIej6IPZXW8eWDNwA6MSwIgcgPZeBYi3UBFShjH\njSYsy4E9SrClS6HDxiX1+rpVJwI=\n-----END CERTIFICATE-----\n","-----BEGIN PRIVATE KEY-----\r\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgXszWVURm5cbuSBdK\r\nQ5HakCgS+un2q95OmVZ8kkb1WnahRANCAAQr4rRC6G58baGnsvSgQhVcpVxct9/p\r\npcY6JXiNRKrUK6TUTFmjZnhagtVdsZ0rjh/P1FBZeaSTMnxs4FPrLDUH\r\n-----END PRIVATE KEY-----\r\n");
      // console.log(identity);
      const connectionOptions = {
        wallet: wallet,
        identity: bcuser,
        clientTlsIdentity: `tls_${bcuser}`,

        discovery: {
          enabled: true,
          asLocalhost: false,
        },
        eventHandlerOptions: {
          commitTimeout: 500,
          // strategy: null,
          strategy: DefaultEventHandlerStrategies.NETWORK_SCOPE_ANYFORTX
        },
      };
      try {
        await gateway.connect(ccp, connectionOptions);

        // console.debug(`Gatewary Status: ${gateway}`);
        return gateway;
    } catch (e) {
      console.error(`EX-API-CONNECT_GATEWAY:  ${e}`);
       return null;
     }
  }

  async get_gateway_contract(bcuser, channelname, chaincodeName, contractName) {
    // console.debug(method, methodtype);
    // console.debug("Contract Name", contractName);
    // Create a new gateway for connecting to our peer node.
    gateway = await this.connect_gateway(bcuser);
    //Check the connection is successfull
    if (gateway == null) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-GATEWAY-422",
          errorMessage:
            "Gateway Error-Unable to communicate with underlying network",
        },
      };
      console.error(jsonResult);
      return jsonResult //  res.status(422).json(jsonResult);
    }

    // Get the network (channel) our contract is deployed to.
    const network = await gateway.getNetwork(channelname);
    // const channel = await network.getChannel();
    if (network == null || network == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-NETWORK-422",
          text: `Network Error-Unable to connect Channel ${channelname}`,
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(422).json(jsonResult);
    }

    // Get the contract from the network.
    var contract;
    if (contractName == "") {
      // jsonResult = {
      //   status: "Error",
      //   data: {
      //     errorCode: "AE-BCN-CONTRACT-422",
      //     text: `Missing Contract name`,
      //   },
      // };
      // console.error(jsonResult);
      // return jsonResult

      contract = network.getContract(chaincodeName);
    } else {
      contract = network.getContract(chaincodeName, contractName);
    }
    // console.debug("contract Details :");
    // console.debug(contract);
    if (contract == null || contract == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-CONTRACT-422",
          text: `NETWORK Error-Unable to connect CHAINCODE ${
            (chaincodeName, contractName)
          }`,
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(422).json(jsonResult);
    }
    return contract;
  }

  async call_chaincode({
    bcuser,
    channelName,
    chaincodeName,
    contractName,
    method,
    req,
    readonly,
  } = {}) {

    console.log(`----------In BCN Call Chaincode---------------`);
    console.log(`bcuser: ${bcuser}`);
    console.log(`channelName: ${channelName}`);
    console.log(`chaincodeName: ${chaincodeName}`);
    console.log(`contractName: ${contractName}`);
    console.log(`method: ${method}`);      
    console.log(`readonly: ${readonly}`);
    console.log(`req:`);
    console.log(req.body);
    
    if (bcuser == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-Blockchain user details-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (bcuser.trim() == "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-Blockchain user details-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    
    if (channelName == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-channelname-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (channelName.trim() == "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-channelname-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (chaincodeName == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-chaincodeName-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (chaincodeName.trim() == "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-chaincodeName-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if ((method != "GetTransactionByID" ) && (contractName == undefined)) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-contractName-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (method == undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-method name-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (method.trim() == "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-BCN-SYNTAX-400",
          errorMessage:
            "Syntax error while submitting the transaction-method name-is required",
        },
      };
      console.error(jsonResult);
      return jsonResult // res.status(400).json(jsonResult);
    }
    if (req.body === undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-SYNTAX-400",
          errorMessage: "Body Parameters for Post Method is missing",
        },
      };
      return jsonResult;
    }
    if (req.body.toString().trim() == "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-SYNTAX-400",
          errorMessage: "Body Parameters for Post Method is missing",
        },
      };
      return jsonResult;
    }


    let contract = await this.get_gateway_contract(
      bcuser,
      channelName,
      chaincodeName,
      contractName
    );
    // Submit the specified transaction.
    let result;
    try {
      // console.log(JSON.stringify(req.body));
      
      if (method === "GetTransactionByID") {
        console.log('Executing GetTransactionByID');
        console.log(JSON.stringify(req.body.txid));
        console.log(req.body.txid);
        
        result = await contract.evaluateTransaction(
          method,
          channelName,
          req.body.txid
      ); 
      return result;
      }
      else
      {
        console.log(`excuting method : ${method}`)
        if (readonly) {
          result = await contract.evaluateTransaction(
            method,
            JSON.stringify(req.body)
          );
        } else {
          result = await contract.submitTransaction(
            method,
            JSON.stringify(req.body)
          );
        }
    }
      if (result != undefined) {
        // console.log('\n\n Transaction has been evaluated for parameters:');
        // console.log(req.body);
        // console.log('\n\n');
        jsonResult = JSON.parse(result.toString());
        // console.log('--------------BCN OUTPUT-----------------')
        // console.log(jsonResult);
        return jsonResult; //res.status(200).json(JSON.parse(result.toString()));
      } else {
        console.log(`Transaction result not obtained}`);
        jsonResult = {
          status: "Error",
          data: {
            errorCode: "AE-BCN-NORESPONSE-444",
            errorMessage: "Transaction result not obtained",
          },
        };
        await gateway.disconnect();
        return jsonResult; //res.status(444).json(jsonResult);
      }
    } catch (e) {
      console.log(
        `Blockchain Transaction failed to evaluate in call_chaincode ${e.message}`
      );
      jsonResult = {
        status: "Error",
        data: {
          errorCode: `AE-${method.toUpperCase()}_EVALUATETRANSACTION`,
          errorMessage: ` Failed to submit Transaction ${e.message}`,
        },
      };
      console.error(jsonResult);
      console.error(`AE-${method.toUpperCase()}_EVALUATETRANSACTION: ${e.message}`);
      await gateway.disconnect();
      return jsonResult // res.status(444).json(jsonResult);
    }
  }
}
module.exports = bcn_interface;
