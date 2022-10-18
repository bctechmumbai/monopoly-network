const vyaparBlockchainInterface = require("./app_modules/vyapar");
let vbci = new vyaparBlockchainInterface();

const player = require("./app_modules/player");
let playerObj = new player();

// const user = require("./app_modules/user.js");

const auth = require("./middleware/auth");

var express = require("express");
// const { response } = require("express");
var app = express();
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb" }));

var server = app.listen(8080, "0.0.0.0", function () {
  var host = server.address().address;
  var port = server.address().port;
  console.log("Blockchain Api Server is running at http://%s:%s", host, port);
});

// Api Endpoints for vyapar Game chaincode

// One time asset Creation API disable by default.

app.post("/api/vyapar/createlocation/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode",'createAsset',"assetContract", req, false);
  // let response = {
  //   status: "Error",
  //   data: {
  //     errorCode: "AE-VYAPAR-SYNTAX-400",
  //     errorMessage: "All required locations already created",
  //   },
  // };
   res.status(200).send(response);
 });

app.post("/api/vyapar/getasset/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","readAsset","assetContract" ,req, true);
  res.status(200).send(response);
});

app.post("/api/vyapar/updateasset/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","updateAsset","assetContract" ,req);
  res.status(200).send(response);
});

app.post("/api/vyapar/deleteasset/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","deleteAsset","assetContract" ,req);
  res.status(200).send(response);
});

app.post("/api/vyapar/getassethistory/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","getAssetHistory","assetContract" ,req, true);
  res.status(200).send(response);
});

app.post("/api/vyapar/createplayer/", auth, async function (req, res) {
  // let response = await playerObj.registerPlayer(req);
  // if(response.status === 'Success')
  // {
    let record = {
      userId: req.body.assetId,
      walletBalance: 50000
    }
    req.body = record;
    let response = await vbci.call_chaincode("walletcode","createWallet","walletContract" ,req, false);
  // }
  res.status(200).send(response);
});

app.post("/api/user/gettoken", async (req, res) => {
  var tokenres = await playerObj.getToken(req);
  res.status(200).send(tokenres);
});

app.post("/api/vyapar/getlocations/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","getlocations","assetContract" ,req, true);
  res.status(200).send(response);
});

app.post("/api/vyapar/getgames/", auth, async function (req, res) {
  let response = await vbci.call_chaincode("vyaparcode","getgames","assetContract", req, true);
  res.status(200).send(response);
});

app.post("/api/vyapar/creategame/", auth, async function (req, res) {
  let game = await vbci.creategame(req);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  //    console.log('----------------------Game Data---------------------------');
  //  console.log(game.data);
  req.body = game.data;
  let response = await vbci.call_chaincode("vyaparcode","createGame","vyaparContract" ,req);

  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }

  res.status(200).send(response);
});

app.post("/api/vyapar/joingame/", auth, async function (req, res) {
  console.log(`In joingame gameid : ${req.body.gameId}`);
  let game = await vbci.joingame(req);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  req.body = game.data;
  console.log('----------------------Game Data---------------------------');
  console.log(req.body);
  let response = await vbci.call_chaincode("vyaparcode","joinGame","vyaparContract", req);

  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }


  res.status(200).send(response);
});

app.post("/api/vyapar/playgame/", auth, async function (req, res) {
  let game = await vbci.playgame(req);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  req.body = game.data;
//   console.log('----------------------Game Data---------------------------');
//   console.log(game);
  let response = await vbci.call_chaincode("vyaparcode","playGame","vyaparContract", req);

  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }


  res.status(200).send(response);
});

app.post("/api/vyapar/purchaselocation/", auth, async function (req, res) {
  let game = await vbci.purchaselocation(req);
  // console.log(game);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  req.body = game.data;
//   console.log('----------------------Game Data---------------------------');
//   console.log(game);
  let response = await vbci.call_chaincode("vyaparcode","purchaseLocation","vyaparContract", req);

  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }


  res.status(200).send(response);
});


app.post("/api/vyapar/selllocation/", auth, async function (req, res) {
  let game = await vbci.sellLocation(req);
  // console.log(game);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  req.body = game.data;
  //  console.log('----------------------Game Data---------------------------');
  //  console.log(game);
  let response = await vbci.call_chaincode("vyaparcode","transferLocation","vyaparContract", req);


  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }

  res.status(200).send(response);
});

app.post("/api/vyapar/endgame/", auth, async function (req, res) {
  let game = await vbci.endgame(req);
  if (game.status == "Error") {
    return res.status(200).send(game);
  }
  req.body = game.data;
//   console.log('----------------------Game Data---------------------------');
//   console.log(game);
  let response = await vbci.call_chaincode("vyaparcode","endGame","vyaparContract", req);

  if(response.status == 'Success')
  {
    if(response.data.walletjson != undefined)
    { 
      response.data.walletjson.forEach(async walletjson => { 
        req.body = walletjson;
        let walletresponse = await vbci.call_chaincode("walletcode","updateWallet","walletContract" ,req);    
        console.log(`Wallet Update Response`);
        console.log(walletresponse);
      }); 
      
    }
  }



  res.status(200).send(response);
});

app.post("/api/vyapar/GetTransactionByID/",auth, async function (req, res) {    
    
    let result  =await vbci.call_chaincode("vyaparcode",'GetTransactionByID','',req,true);
    res.status(200).json(result);
});

app.post("/api/vyapar/GetWalletStatement/",auth, async function (req, res) {    
    
  let result  =await vbci.getwalletstatement(req);
  res.status(200).json(result);
});

app.post("/api/vyapar/GetTransactionDetails/",auth, async function (req, res) {    
    
  let result  =await vbci.getTransactionDetails(req);
  res.status(200).json(result);
});