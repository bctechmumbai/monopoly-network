const jwt = require("jsonwebtoken");
require("dotenv").config();
const crypto = require("crypto");
// const enrollPlayer = require("../app_modules/player");
// let ea = new enrollPlayer();
// const config = process.env;
const player = require("../app_modules/player");
let playerObj = new player();

const verifyToken = async (req, res, next) => {
  const token = req.headers["x-access-token"];

  if (!token) {
    let jsonResult = {
      status: "Error",
      data: {
        errorCode: "AE-VYAPAR-SYNTAX-400",
        errorMessage: "Missing request authentication token.",
      },
    };

    return res.status(400).json(jsonResult);
  }

  let decodedToken = playerObj.decodeToken(token);

  if (decodedToken.Status == "Success") {
    let userId = decodedToken.data.userName;
    let user = await playerObj.getPlayer(userId);

    if (!user) {
      return res.status(401).json({
        Status: "Error",
        data: {
          errorCode: "401",
          errorMessage: "Invalid Token, Please use Valid token",
        },
      });
    }
    return next();
  } else {
    return res.status(401).json(decodedToken);
  }
};

module.exports = verifyToken;
