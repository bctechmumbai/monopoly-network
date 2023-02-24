const { BlockDecoder } = require("fabric-common");
var transaction_library = require("./transaction_library");
var transaction_library_new = require("./transactionLibrary");
const bcn_interface = require("./bcn_interface");
// const gameModel = require("../model/gameModel");
// const { gamedttm, assetId } = require("../model/gameModel");
const player = require("../app_modules/player");
let playerObj = new player();

// const extracttoken = require("../middleware/extracttoken.js");
// let et = new extracttoken();

//BCN parameters
const channelName = "vyaparchannel";
//let chaincodeName = "vyaparcode";
// const contractName = "vyaparContract";

class vyapar {
  rollDice(min = 2, max = 12) {
    return Math.floor(Math.random() * (max - min + 1) + min);
  }

  async call_chaincode(
    chaincodeName,
    method,
    contractName,
    req,
    readonly = false
  ) {
    var jsonResult;
    console.log(`----------In Vyapar Call Chaincode---------------`);
    console.log(`method: ${method}`);
    console.log(`contractName: ${contractName}`);
    console.log(`readonly: ${readonly}`);
    console.log(`req:`);
    console.log(req.body);

    if (req === undefined) {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-SYNTAX-400",
          errorMessage: "Body Parameters for Post Method is missing",
        },
      };
      return jsonResult;
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
    // console.log(req.body);
    if (req.body.toString().trim() === "") {
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-SYNTAX-400",
          errorMessage: "Body Parameters for Post Method is missing",
        },
      };
      return jsonResult;
    }
    try {
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
      let bcuser;
      let decodedToken = playerObj.decodeToken(token);
      if (decodedToken.Status == "Success") {
        bcuser = decodedToken.data.userName;
      } else {
        return decodedToken;
      }

      let bi = new bcn_interface();
      if (method === "getlocations") {
        method = "readAssetsByQuery";
        req.body = {
          selector: {
            assetData: {
              assetType: "LOC",
            },
          },
        };
      }
      if (method === "getgames") {
        method = "readAssetsByQuery";
        req.body = {
          selector: {
            assetData: {
              assetType: "Game",
            },
          },
          // ,
          // "fields": [
          //   "assetData.assetId",
          //   "assetData.players"
          // ]
        };
      }
      if (method == "GetTransactionByID") {
        chaincodeName = "qscc";
        contractName = "";
      } else {
        chaincodeName = chaincodeName;
      }
      console.log(req.body);
      jsonResult = await bi.call_chaincode({
        bcuser: bcuser,
        channelName: channelName,
        chaincodeName: chaincodeName,
        contractName: contractName,
        method: method,
        req: req,
        readonly: readonly,
      });
      console.log(jsonResult);
      return jsonResult;
    } catch (err) {
      console.error(
        `AE-VYAPAR-UNPROCESSABLEINPUT-422-${method.toUpperCase()}-PARAMETERMISSING: ${err}`
      );
      jsonResult = {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-UNPROCESSABLEINPUT-422",
          errorMessage: `Something went wrong, Please try again ${err}`,
        },
      };

      return jsonResult;
      //res.status(422).json(jsonResult);
    }
  }

  async creategame(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;

      return {
        status: "Success",
        data: {
          userId: bcuser,
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-CREATEGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }

  async joingame(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;
      return {
        status: "Success",
        data: {
          userId: bcuser,
          gameId: req.body.gameId,
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-JOINGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }
  //this.rollDice(2, 12)
  async playgame(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;
      return {
        status: "Success",
        data: {
          userId: bcuser,
          gameId: req.body.gameId,
          diceResult: req.body.diceResult,
          // 'diceResult': this.rollDice(2, 12)
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-PLAYGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }

  async purchaselocation(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;
      return {
        status: "Success",
        data: {
          userId: bcuser,
          gameId: req.body.gameId,
          locationAssetId: req.body.locationAssetId,
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-PLAYGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }
  async sellLocation(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;
      return {
        status: "Success",
        data: {
          gameId: req.body.gameId,
          userId: bcuser,
          locationId: req.body.locationId,
          buyerId: req.body.buyerId,
          transactionCost: req.body.transactionCost,
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-PLAYGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }

  async endgame(req) {
    try {
      let bcuser = playerObj.decodeToken(req.headers["x-access-token"]).data
        .userName;
      return {
        status: "Success",
        data: {
          userId: bcuser,
          gameId: req.body.gameId,
        },
      };
    } catch (error) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-PLAYGAME-SYNTAX-400",
          errorMessage: error.message,
        },
      };
    }
  }

  async getwalletstatement(req) {
    if (req === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETWALLETSTATEMENT-SYNTAX-400",
          errorMessage: "Missing User to get the Wallet Statement",
        },
      };
    }
    if (req.body === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETWALLETSTATEMENT-SYNTAX-400",
          errorMessage: "Missing User to get the Wallet Statement",
        },
      };
    }
    if (req.body.userId === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETWALLETSTATEMENT-SYNTAX-400",
          errorMessage: "Missing User(userId) to get the Wallet Statement",
        },
      };
    }
    if (req.body.userId.trim() === "") {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETWALLETSTATEMENT-SYNTAX-400",
          errorMessage: "Missing User (userId) to get the Wallet Statement",
        },
      };
    }
    let response;
    let userId = req.body.userId;
    let transactions = [];
    let jsonResult;
    req.body = {
      assetId: userId,
    };
    response = await this.call_chaincode(
      "walletcode",
      "getAssetHistory",
      "",
      req,
      true
    );
    if (response != undefined) {
      if (response.status != undefined) {
        if (response.status === "Error") {
          return response;
        }
        if (response.status === "Success") {
          //response.data.forEach(async metaData =>
          for (let i = 0; i < Object.keys(response.data).length; i++) {
            let metaData = response.data[i];
            if (metaData.metaData.updateTxId != undefined) {
              req.body = {
                txid: metaData.metaData.updateTxId,
              };
              console.log(
                `updateTransactionId : ${metaData.metaData.updateTxId}`
              );
              jsonResult = await this.call_chaincode(
                "walletcode",
                "GetTransactionByID",
                "",
                req,
                true
              );
            } else if (metaData.metaData.createTxId != undefined) {
              req.body = {
                txid: metaData.metaData.createTxId,
              };
              console.log(
                `createTransactionId : ${metaData.metaData.updateTxId}`
              );
              jsonResult = await this.call_chaincode(
                "walletcode",
                "GetTransactionByID",
                "",
                req,
                true
              );
            }
            if (jsonResult != undefined) {
              console.log(`jsonResult `);
              console.log(jsonResult);

              ////////////////////////////////////////////////////////////////////////////

              let result = BlockDecoder.decodeTransaction(jsonResult);
              if (result != undefined) {
                console.log(`Transaction has been evaluated \n`);
                console.log(`jsonresult has been evaluated \n`);
                console.log(jsonResult);
                console.log(`result has been evaluated \n`);
                console.log(result);

                let tl = new transaction_library(JSON.stringify(result));

                let inputs = tl.get_data();
                console.log(`-----------------------inputs------------------`);
                console.log(inputs);

                if (inputs != undefined) {
                  let Transactiondttm =
                    response.data[i].metaData.updateTxTm == undefined
                      ? response.data[i].metaData.createTxTm
                      : response.data[i].metaData.updateTxTm;
                  let TransactionId =
                    response.data[i].metaData.updateTxId == undefined
                      ? response.data[i].metaData.createTxId
                      : response.data[i].metaData.updateTxId;
                  let transactiondata = {
                    walletbalance: response.data[i].assetData.walletBalance,
                    Transactiondttm: Transactiondttm,
                    TransactionId: TransactionId,
                    Transactiondata: inputs,
                  };
                  console.log(`-------------transactiondata-----------`);
                  console.log(transactiondata);
                  transactions.push(transactiondata);
                  // }
                }
              }
            }
          }
        }
      }
    }

    console.log(`---------------- transactions -----------------`);
    console.log(transactions);
    return {
      status: "Success",
      data: {
        transactions: transactions,
      },
    };
  }

  async getTransactionDetails(req) {
    // transaction_library_new
    if (req === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETTRANSACTIONDETAILS-SYNTAX-400",
          errorMessage: "Body parameters missing",
        },
      };
    }
    if (req.body === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETTRANSACTIONDETAILS-SYNTAX-400",
          errorMessage: "Body Parameter missing",
        },
      };
    }
    if (req.body.txid === undefined) {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETTRANSACTIONDETAILS-SYNTAX-400",
          errorMessage: "Missing Transaction Id (transactionid)",
        },
      };
    }
    if (req.body.txid.trim() === "") {
      return {
        status: "Error",
        data: {
          errorCode: "AE-VYAPAR-GETTRANSACTIONDETAILS-SYNTAX-400",
          errorMessage: "Missing Transaction Id (transactionid)",
        },
      };
    }
    let response = {};
    let result;
    result = await this.call_chaincode(
      "walletcode",
      "GetTransactionByID",
      "",
      req,
      true
    );
    console.log(`-------------Result-------------------`);
    console.log(result);
    if (result != undefined) {
      var tl = new transaction_library_new(result);
      // response.transaction = tl.get_transaction();
      response.transaction_validation = tl.get_transaction_validation();
      response.transaction_envelope_payload_header_channelHeader_channel_id =
        tl.get_transaction_envelope_payload_header_channelHeader_channel_id();
      response.transaction_envelope_signature =
        tl.get_transaction_envelope_signature();
      response.transaction_envelope_payload_header_channelHeader =
        tl.get_transaction_envelope_payload_header_channelHeader();
      response.transaction_envelope_payload_header_signatureHeader =
        tl.get_transaction_envelope_payload_header_signatureHeader();

      response.transactionEnvelopPayloadHeaderChannelHeaderChannel_id =
        tl.get_transaction_envelope_payload_header_channelHeader_channel_id();
      response.transactionEnvelopPayloadHeaderChannelHeaderTx_id =
        tl.get_transaction_envelope_payload_header_channelHeader_tx_id();
      response.transactionEnvelopPayloadHeaderChannelHeaderEpoch =
        tl.get_transaction_envelope_payload_header_channelHeader_epoch();
      response.envPayloadHeaderSignatureHeader =
        tl.get_transaction_envelope_payload_header_signatureHeader();
      // response.envPayloadData=tl.get_transaction_envelope_payload_data();
      // response.envPayloadDataActions=tl.get_transaction_envelope_payload_actions();
      // response.action0=tl.get_transaction_envelope_payload_action(0);

      response.action0header =
        tl.get_transaction_envelope_payload_action_header(0);

      // response.action0payload = tl.get_transaction_envelope_payload_action_payload(0);
      response.action0payloadproposal =
        tl.get_transaction_envelope_payload_action_payload_chaincode_proposal_payload(
          0
        );
      response.action0payloadproposaltype =
        tl.get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_type(
          0
        );
      response.action0payloadproposalinput =
        tl.get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_input(
          0
        );
      response.action0payloadproposalchaincode =
        tl.get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_chaincode_id(
          0
        );
      response.action0payloadproposaltimeout =
        tl.get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_timeout(
          0
        );

      // response.action0payloadaction = tl.get_transaction_envelope_payload_action_payload_action(0);
      // response.action0payloadactionProposalResponsePayload= tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload(0);
      response.action0payloadactionProposalResponsePayloadProposalHash =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_proposal_hash(
          0
        );
      // response.action0payloadactionProposalResponsePayloadProposalextension= tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension(0);

      response.extresults =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results(
          0
        );
      response.resultDataModel =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results_data_model(
          0
        );
      response.resultnsrwset =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results_ns_rwset(
          0
        );

      response.extevents =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_events(
          0
        );
      response.extresponse =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_response(
          0
        );
      response.extchaincodeId =
        tl.get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_chaincode_id(
          0
        );

      response.action0payloadactionendorsements =
        tl.get_transaction_envelope_payload_action_payload_action_endorsements(
          0
        );
    } else {
      return {
        status: "Error",
        data: "Unable to Process the request",
      };
    }

    return {
      status: "Success",
      data: response,
    };
  }
}
module.exports = vyapar;
