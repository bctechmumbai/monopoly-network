// const vyaparBlockchainInterface = require("../app_modules/vyapar");
// let vbci = new vyaparBlockchainInterface();

// class gameModel
// {
//     gameModel(assetId,)
//     {
//         this.assetId = assetId

//     }
// }
const gameModel = 
{
    assetId: String,
    assetType: String,
    createdby: String,
    nextMove: Number,
    gamedttm: Date,
    players: Object,
    locations: Object
}

module.exports = gameModel;