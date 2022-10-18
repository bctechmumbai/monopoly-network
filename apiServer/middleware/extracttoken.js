const jwt = require("jsonwebtoken");
require("dotenv").config();
const config = process.env;

class extracttoken {
    getuser(token) {
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
}
module.exports = extracttoken;
