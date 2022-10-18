/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');
// const ClientIdentity = require('fabric-shim').ClientIdentity;
const assetContract = require('./assetContract');

let assetInterface = new assetContract();
class vyaparContract extends Contract {
    constructor() {
        super();
        // this.TxId = '';
        // this.TxUser = '';
        // this.TxTm = '';
    }


    async createGame(ctx, jsonInputArgs) {// userId
        console.info(
            '-----------------------VyaparContract:createGame---------------------------'
        );

        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-createGame-SYNTAX-400',
                    errorMessage: 'JSON input missing for createGame function.',
                },
            };
            return response;
        }
        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-createGame-SYNTAX-400',
                    errorMessage: 'Invalid json Input for createGame function.',
                },
            };
            return response;


        }

        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: 'Not Created Yet',
                    errorCode: 'ce-createGame-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                }
            };
            return response;
        }

        let qry = {
            selector: {
                assetData: {
                    assetType: 'LOC',
                },
            },
            fields: ['assetData.assetId', 'assetData.placeName', 'assetData.placeCost', 'assetData.placeRent', 'assetData.placeType', 'assetData.placeColor'],
        };

        let qryString = JSON.stringify(qry);
        let locations;
        try {
            locations = await assetInterface.readAssetsByQuery(ctx, qryString);
            // console.info('------back to createGame------------');
            // console.info(locations);
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    errorCode: 'ce-createGame-location-read-error-422',
                    errorMessage: 'Unable to read locations for creating game...!',
                },
            };
            return response;
        }

        if (locations.status === 'Error') {
            // console.info(locations);
            let response = {
                status: 'Error',
                data: {
                    errorCode: 'ce-createGame-location-read-error-422',
                    errorMessage: 'Unable to read locations for creating game...!',
                },
            };
            return response;

        }
        locations = locations.data;
        // console.info(
        //     '-------------------------JSON locations-------------------------'
        // );
        // console.info(locations);
        let gameLocations = [];
        let i = 1;
        locations.forEach(function (l) {
            gameLocations.push({
                assetId: l.assetData.assetId,
                placeName: l.assetData.placeName,
                placeCost: l.assetData.placeCost,
                placeRent: l.assetData.placeRent,
                placeType: l.assetData.placeType,
                placeColor: l.assetData.placeColor,
                placeOwner: '',
                placeSequence: i,
            });
            i++;
        });
        // console.info(
        //     '-------------------------JSON array of Game locations-------------------------'
        // );
        // console.info(gameLocations);
        let gameDateTime = new Date();

        // let cid = new ClientIdentity(ctx.stub);

        let bcuser = record.userId; //cid.getID();

        let newGame = {
            assetId:
                gameDateTime.getDate().toString() +
                gameDateTime.getMonth().toString() +
                gameDateTime.getFullYear().toString() +
                gameDateTime.getHours().toString() +
                gameDateTime.getMinutes().toString() +
                gameDateTime.getSeconds().toString(),
            locations: gameLocations,
            assetType: 'Game',
            createdBy: bcuser,
            nextMove: 1,
            gameDateTime: gameDateTime.toString(),
            players: [
                {
                    userId: bcuser,
                    playSequence: 1,
                    walletBalance: 50000,
                    currentPlace: gameLocations[0].assetId,
                    lastMoveDtTm: ''
                },
            ],
            closed: false,
            winner: '',
        };
        // console.info(
        //     '-------------------------newGame-------------------------'
        // );
        // console.info(newGame);
        // return assetInterface.createAsset(ctx, JSON.stringify(newGame));
        let updateStatus = await assetInterface.createAsset(ctx, JSON.stringify(newGame));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = `${record.userId} successfully created Game`;
            updateStatus.data.game = newGame;
        }
        return updateStatus;
    }

    async joinGame(ctx, jsonInputArgs) {//gameId userId


        console.info(
            '-----------------------VyaparContract:joinGame---------------------------'
        );
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-joinGame-SYNTAX-400',
                    errorMessage: 'JSON input missing for joinGame function.',
                },
            };
            return response;
        }
        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-joinGame-SYNTAX-400',
                    errorMessage: 'Invalid json Input for joinGame function.',
                },
            };
            return response;


        }
        if (record.gameId === null || record.gameId === undefined || record.gameId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-joinGame-SYNTAX-400',
                    errorMessage: 'Invalid gameId or gameId field missing.',
                }
            };
            return response;
        }
        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-joinGame-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                }
            };
            return response;
        }

        let bcuser = record.userId; //cid.getID();
        let gameData;

        try {
            gameData = await assetInterface.readAsset(ctx, JSON.stringify({ assetId: record.gameId }));
            // console.info('------back to joinGame------------');
            // console.info(game);
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-joinGame-error-422',
                    errorMessage: 'Unable to read game details please check gameId...!',
                },
            };
            return response;
        }

        if (gameData.status === 'Error') {
            return gameData;
        }

        let game = gameData.data.assetData;
        if (game.closed !== undefined) {
            if (game.closed === true) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: record.gameId,
                        errorCode: 'ce-joinGame-error-422',
                        errorMessage: 'Game is already closed...!',
                    },
                };
                return response;
            }
        }



        // console.info('--------------gameData.data.assetData--------------');
        // console.info(game);
        let gamePlayers = game.players;
        let loggedinPlayerAlreadyJoined = gamePlayers.find((data) => data.userId === bcuser);

        // console.info('--------------loggedinPlayerAlreadyJoined--------------');
        // console.info(loggedinPlayerAlreadyJoined);


        if (loggedinPlayerAlreadyJoined !== undefined) {

            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'AE-VYAPAR-JOINGAME-ALREADY-MEMBER-400',
                    errorMessage: 'You are already part of this game, please play the game.',
                },
            };
            return response;
        }

        let gameLocations = game.locations;
        gamePlayers.push({
            userId: bcuser,
            playSequence: gamePlayers.length + 1,
            walletBalance: 50000,
            currentPlace: gameLocations[0].assetId,
            lastMoveDtTm: ''
        });
        game.players = gamePlayers;

        // console.info('------New Game data: joinGame------------');
        // console.info(game);

        // return assetInterface.updateAsset(ctx, JSON.stringify(game));
        let updateStatus = await assetInterface.updateAsset(ctx, JSON.stringify(game));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = `${record.userId} successfully joined Game`;
            updateStatus.data.game = game;

        }
        return updateStatus;

    }

    async playGame(ctx, jsonInputArgs) { //gameId, userId, diceResult
        console.info(
            '-----------------------VyaparContract:joinGame---------------------------'
        );

        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'JSON input missing for playGame function.',
                },
            };
            return response;
        }
        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid json Input for playGame function.',
                },
            };
            return response;


        }
        if (record.gameId === null || record.gameId === undefined || record.gameId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid gameId or gameId field missing.',
                }
            };
            return response;
        }
        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                }
            };
            return response;
        }
        if (record.diceResult === null || record.diceResult === undefined) {

            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid diceResult or diceResult field missing.',
                }
            };
            return response;
        }
        try {
            if (!Number.isInteger(record.diceResult)) { throw new Error('Invalid Dice Result'); }
        }
        catch (err) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid diceResult or diceResult is not a Number.',
                }
            };
            return response;

        }
        try {
            if (record.diceResult < 2 && record.diceResult > 12) { throw new Error('Invalid Dice Result'); }
        }
        catch (err) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-playGame-SYNTAX-400',
                    errorMessage: 'Invalid Dice Number, Dice Range must be between 2 to 12',
                }
            };
            return response;

        }

        // console.info('---gameId---');
        // console.info(gameId);
        // console.info('---userName---');
        // console.info(userName);
        // console.info('---diceResult---');
        // console.info(diceResult);
        // // try {
        // let bcuser = record.userId; //cid.getID();
        let gameData;
        try {
            gameData = await assetInterface.readAsset(ctx, JSON.stringify({ assetId: record.gameId }));
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-playGame-error-422',
                    errorMessage: 'Unable to read game details please check gameId...!',
                },
            };
            return response;
        }

        if (gameData.status === 'Error') {
            return gameData;
        }

        let game = gameData.data.assetData;



        if (game.closed !== undefined) {
            if (game.closed === true) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: record.gameId,
                        errorCode: 'ce-PlayGame-error-422',
                        errorMessage: 'Game is already closed...!',
                    },
                };
                return response;
            }
        }

        // console.info('\n----------------Current Game------------------\n');
        // console.info(game);

        let gamePlayers = game.players;
        let gameLocations = game.locations;
        let currentSequence = game.nextMove;

        let loggedinPlayer = gamePlayers.find((data) => data.userId === record.userId);
        if (loggedinPlayer === undefined) {

            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'ce-playGame-nonMember-400',
                    errorMessage: 'Hey man, you are not part of this game, Please join the game first.',
                },
            };
            return response;
        }
        if (loggedinPlayer.playSequence !== currentSequence) {
            return {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'AE-VYAPAR-INVALIDMOVE-SYNTAX-400',
                    errorMessage: `Hey ${loggedinPlayer.userId}, it's not your turn. Let others play....!`,
                },
            };
        }

        // console.info(
        //     `------------Player ${loggedinPlayer.userId} rolling dice(s) ---------------`
        // );

        // let diceResult = this.rollDice();
        let playersCurrentLocation = loggedinPlayer.currentPlace;
        let playersCurrentPosition = gameLocations.find((location) => location.assetId === playersCurrentLocation).placeSequence;
        let playersNextPosition = playersCurrentPosition + record.diceResult;
        /// If players next position moves out of total locations rotate it.
        let totalLocations = gameLocations.length;
        if (playersNextPosition >= totalLocations) {
            playersNextPosition = playersNextPosition % totalLocations;
        }

        // After rotation player can't sit at start again.

        if (playersNextPosition === 1) {
            playersNextPosition = 2;
        }

        let playersNextLocation = gameLocations.find((location) => location.placeSequence === playersNextPosition);
        // console.info(`Current Position: ${playersCurrentPosition}`);
        // console.info(`Dice Result : ${record.diceResult}`);
        // console.info(`Next Position : ${playersNextLocation.assetId}`);
        let moveMessage = `Rolled Dice and Moved to new location: ${playersNextLocation.assetId} Successfully.`;
        let transactionMessage='';
        // Add incentive of 10 mudras for playing its turn.
        loggedinPlayer.walletBalance = loggedinPlayer.walletBalance + 10;

        // Place the Player on new location and update its current place.
        // let newLocation = gameLocations[playersNextPosition - 1];

        loggedinPlayer.currentPlace = playersNextLocation.assetId;
        //loggedinPlayer.currentplace.place = playersNextPosition;
        //deduct Rs. 500 for if go to jail
        if (playersNextLocation.assetId === 'LOC-10') {
            transactionMessage = 'Deducted Jail Penalty of Rs. 500';
            loggedinPlayer.walletBalance = loggedinPlayer.walletBalance - 500;
        }
        //deduct Rs. 300 for if go to Club
        if (playersNextLocation.assetId === 'LOC-19') {
            transactionMessage = 'Deducted Club House Charges of Rs. 300';
            loggedinPlayer.walletBalance = loggedinPlayer.walletBalance - 300;
        }
        //deduct Rs. 200 for if go to Rest House
        if (playersNextLocation.assetId === 'LOC-28') {
            transactionMessage = 'Deducted Rest House Charges Rs. 200';
            loggedinPlayer.walletBalance = loggedinPlayer.walletBalance - 200;
        }
        //deduct Rs. 50-500 for income tax
        if (playersNextLocation.assetId === 'LOC-23' || playersNextLocation.assetId === 'LOC-33') {
            let incomeTax = Math.floor(Math.random() * (500 - 50 + 1) + 50);
            transactionMessage = `Deducted Income Tax of Rs ${incomeTax}`;
            loggedinPlayer.walletBalance = loggedinPlayer.walletBalance - incomeTax;
        }
        //  implement the Transaction rules here:
        if (playersNextLocation.placeType === 'T') {
            if (playersNextLocation.placeName === 'Transaction') {
                switch (record.diceResult) {
                case 2:
                    transactionMessage = 'Received Share Dividend of Rs 750';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 750;
                    break;
                case 3:
                    transactionMessage = 'Paid School and Hostel Fees of Rs 860';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 860;
                    break;
                case 4:
                    transactionMessage = 'Received Birthday Gift of Rs 2500';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 2500;
                    break;
                case 5:
                    transactionMessage = 'Paid Transport Cost of Rs 1000';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 1000;
                    break;
                case 6:
                    transactionMessage = 'Received Gift from Relative and Friends of Rs 850';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 850;
                    break;
                case 7:
                    transactionMessage = 'Paid for Birthday Party of Rs 1350';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 1350;
                    break;
                case 8:
                    transactionMessage = 'Received from Scrap Sale of Rs 1250';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 1250;
                    break;
                case 9:
                    transactionMessage = 'Paid Insurance Premium of Rs 850';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 850;
                    break;
                case 10:
                    transactionMessage = 'Received Honorarium  of Rs 1500';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 1500;
                    break;
                case 11:
                    transactionMessage = 'Paid for Relatives Marriage of Rs 2200';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 2200;
                    break;
                case 12:
                    transactionMessage = 'Received gift from Friend 2200';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 2200;
                    break;

                }
            }
            if (playersNextLocation.placeName === 'Luck') {
                switch (record.diceResult) {
                case 2:
                    transactionMessage = 'Paid for House Repair of Rs 850';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 850;
                    break;
                case 3:
                    transactionMessage = 'Received Lottery amount Rs 850';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 850;
                    break;
                case 4:
                    transactionMessage = 'Paid Penalty for Road Accident of Rs 1350';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 1350;
                    break;
                case 5:
                    transactionMessage = 'Received Crossword Prize of Rs 1350';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 1350;
                    break;
                case 6:
                    transactionMessage = 'Paid for Loss in Business of Rs 1750';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 1750;
                    break;
                case 7:
                    transactionMessage = 'Received Ancestral Property Benefit Rs 2550';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 2550;
                    break;
                case 8:
                    transactionMessage = 'Go to Jail for Crime and Deducted Rs. 500';
                    loggedinPlayer.currentPlace = 'LOC-10';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 500;
                    break;
                case 9:
                    transactionMessage = 'Received Honorarium of Rs 2200';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 2200;
                    break;
                case 10:
                    transactionMessage = 'Paid for loss in Betting of Rs 2200';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 2200;
                    break;
                case 11:
                    transactionMessage = 'Received for Recession in market of Rs 1250';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) + 1250;
                    break;
                case 12:
                    transactionMessage = 'Paid for Crime 1350';
                    loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - 1350;
                    break;

                }
            }
        }


        // Check owner of the new location for paying rent


        if (playersNextLocation.placeOwner.trim().length !== 0) {
            // Pay the rent to the Owner


            let placeRent = parseFloat(playersNextLocation.placeRent);
            // console.info(
            //     `This Location/Service: ${playersNextLocation.placeName} will cost you Rent of : ${placeRent}`
            // );


            let newLocationOwner = gamePlayers.find((player) => player.userId === playersNextLocation.placeOwner);

            if (newLocationOwner === undefined) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: game.assetId,
                        errorCode: 'AE-VYAPAR-PLAYGAME-NONMEMBER-400',
                        errorMessage: 'Unable to find New Location Owner in game player list, Invalid Asset Owner can\'t pay rent to him.',
                    },
                };
                return response;
            }

            newLocationOwner.walletBalance = parseFloat(newLocationOwner.walletBalance) + placeRent;
            loggedinPlayer.walletBalance = parseFloat(loggedinPlayer.walletBalance) - placeRent;
        }
        loggedinPlayer.lastMoveDtTm = new Date().toString();
        game.players = gamePlayers;

        let nextMove = currentSequence + 1;
        if (nextMove > game.players.length) {
            nextMove = 1;
        }
        game.nextMove = nextMove;

        // console.info('\n----------------Updated Game------------------\n');

        let updateStatus = await assetInterface.updateAsset(ctx, JSON.stringify(game));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = moveMessage + transactionMessage;
            updateStatus.data.game = game;

        }
        return updateStatus;

    }

    async purchaseLocation(ctx, jsonInputArgs) { //gameId, locationAssetId, userId
        console.info(
            '-----------------------VyaparContract:purchaseLocation---------------------------'
        );

        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-purchaseLocation-SYNTAX-400',
                    errorMessage: 'JSON input missing for purchaseLocation function.',
                },
            };
            return response;
        }

        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-purchaseLocation-SYNTAX-400',
                    errorMessage: 'Invalid json Input for purchaseLocation function.',
                },
            };
            return response;


        }
        if (record.gameId === null || record.gameId === undefined || record.gameId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-purchaseLocation-SYNTAX-400',
                    errorMessage: 'Invalid gameId or gameId field missing.',
                },
            };
            return response;
        }

        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-purchaseLocation-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                }
            };
            return response;
        }
        if (record.locationAssetId === null || record.locationAssetId === undefined || record.locationAssetId.trim().length === 0) {

            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-purchaseLocation-SYNTAX-400',
                    errorMessage: 'Invalid locationAssetId or locationAssetId field missing.',
                }
            };
            return response;
        }
        // console.info('---gameId---');
        // console.info(record.gameId);
        // console.info('---buyerId---');
        // console.info(record.userId);
        // console.info('---assetId---');
        // console.info(record.locationAssetId);
        let gameData;

        try {
            gameData = await assetInterface.readAsset(ctx, JSON.stringify({ assetId: record.gameId }));
            // console.info('------back to purchaseLocation------------');
            // console.info(gameData);
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-purchaseLocation-readGame-400',
                    errorMessage: 'Unable to read game details please check gameId...!',
                }
            };
            return response;
        }

        if (gameData.status === 'Error') {
            return gameData;
        }
        let game = gameData.data.assetData;

        if (game.closed !== undefined) {
            if (game.closed === true) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: record.gameId,
                        errorCode: 'ce-PurchasePlace-error-422',
                        errorMessage: 'Game is already closed...!',
                    },
                };
                return response;
            }
        }


        let gameLocations = game.locations;
        let gamePlayers = game.players;

        let locationToPurchase = gameLocations.find((location) => location.assetId === record.locationAssetId);

        if (locationToPurchase === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-PLAYGAME-NO-LOCATION-400',
                    errorMessage: 'No such location exists in game , Please check the location ID.',
                },
            };
            return response;
        } else if (locationToPurchase.placeOwner === undefined || locationToPurchase.placeOwner === null) {
            return {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-NOT-FOR-PURCHADE-400',
                    errorMessage: 'Location is not for sale..',
                },
            };
        }
        else if (locationToPurchase.placeOwner.trim().length !== 0) {
            return {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-NOT-FOR-PURCHADE-400',
                    errorMessage: `Location is not available for purchase, Please contact location owner, '${locationToPurchase.placeOwner.trim()}', to purchase it..`,
                },
            };
        }
        else if (parseInt(locationToPurchase.placeCost)=== 0) {
            return {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-NOT-FOR-PURCHADE-400',
                    errorMessage: 'Location is not for sale',
                },
            };
        }
        let buyer = gamePlayers.find((data) => data.userId === record.userId);

        if (buyer === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-PLAYGAME-NOT-A-PLAYER-400',
                    errorMessage: 'It seems you are not part of this game, You Can\'t purchase this location.',
                },
            };
            return response;
        }
        if (buyer.currentPlace !== locationToPurchase.assetId) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-PLAYGAME-NOT-ON-PLACE-400',
                    errorMessage: 'It seems you are not on this place, You Can\'t purchase this location.',
                },
            };
            return response;

        }


        let locationMasterData = gameLocations.find((location) => location.assetId === record.locationAssetId);
        let locationCost = locationMasterData.placeCost;
        let buyerWalletBalance = buyer.walletBalance;

        if (buyerWalletBalance < locationCost) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-PURCHASE-LOCATION-INSUFFICIENT-FUND-404',
                    errorMessage: `You don't have sufficient fund to purchase this location your wallet balance is : ${buyerWalletBalance}`,
                },
            };
            return response;
        }

        buyer.walletBalance = buyerWalletBalance - locationCost;
        locationToPurchase.placeOwner = buyer.userId;

        game.locations = gameLocations;
        game.players = gamePlayers;

        //return assetInterface.updateAsset(ctx, JSON.stringify(game));
        let updateStatus = await assetInterface.updateAsset(ctx, JSON.stringify(game));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = 'Purchase Successful';
            updateStatus.data.game = game;
        }
        return updateStatus;


    }
    async transferLocation(ctx, jsonInputArgs) {//gameId, locationId, userId, buyerId, transactionCost
        console.info(
            '-----------------------VyaparContract:transferLocation---------------------------'
        );

        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'JSON input missing for transferLocation function.',
                },
            };
            return response;
        }

        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid json Input for transferLocation function.',
                },
            };
            return response;


        }

        if (record.gameId === null || record.gameId === undefined || record.gameId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid gameId or gameId field missing.',
                },
            };
            return response;
        }

        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                },
            };
            return response;
        }

        if (record.buyerId === null || record.buyerId === undefined || record.buyerId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid buyerId or buyerId field missing.',
                },
            };
            return response;
        }

        if (record.locationId === null || record.locationId === undefined || record.locationId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid locationId or locationId field missing.',
                },
            };
            return response;
        }

        if (record.transactionCost === null || record.transactionCost === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-transferLocation-SYNTAX-400',
                    errorMessage: 'Invalid transactionCost or transactionCost field missing.',
                },
            };
            return response;
        }

        try {
            if (!Number.isInteger(record.transactionCost)) { throw new Error('Invalid transactionCost'); }
        }
        catch (err) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-TransferLocation-SYNTAX-400',
                    errorMessage: 'Invalid transactionCost or transactionCost is not a Number.',
                }
            };
            return response;
        }

        let gameData;
        try {
            gameData = await assetInterface.readAsset(ctx, JSON.stringify({ assetId: record.gameId }));
            // console.info('------back to TransferLocation------------');
            // console.info(game);
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-TransferLocation-error-422',
                    errorMessage: 'Unable to read game details please check gameId...!',
                },
            };
            return response;
        }

        if (gameData.status === 'Error') {
            return gameData;
        }

        let game = gameData.data.assetData;

        if (game.closed !== undefined) {
            if (game.closed === true) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: record.gameId,
                        errorCode: 'ce-TransferGame-error-422',
                        errorMessage: 'Game is already closed...!',
                    },
                };
                return response;
            }
        }

        let gamePlayers = game.players;
        let gameLocations = game.locations;

        let seller = gamePlayers.find((data) => data.userId === record.userId);
        if (seller === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'ce-TransferLocation-nonMember-400',
                    errorMessage: 'Hey man, you are not part of this game, Please join the game first.',
                },
            };
            return response;
        }
        let buyer = gamePlayers.find((data) => data.userId === record.buyerId);
        if (buyer === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'ce-TransferLocation-nonMember-400',
                    errorMessage: `Hey man, Check to whom you are selling the property, ${record.buyerId} is not part of this game.`,
                },
            };
            return response;
        }
        let sellingLocation = gameLocations.find((location) => location.assetId === record.locationId);
        if (sellingLocation === undefined) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'ce-TransferLocation-nonMember-400',
                    errorMessage: 'Please check location details It seems it is not part of this game.',
                },
            };
            return response;
        }
        if (sellingLocation.placeOwner !== seller.userId) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.assetId,
                    errorCode: 'ce-TransferLocation-nonMember-400',
                    errorMessage: 'Please check location details It seems it you are not owner of the location.',
                },
            };
            return response;
        }

        if (parseInt(buyer.walletBalance) < parseInt(record.transactionCost)) {
            let response = {
                status: 'Error',
                data: {
                    gameId: game.gameId,
                    errorCode: 'CE-VYAPAR-PURCHASE-LOCATION-INSUFFICIENT-FUND-404',
                    errorMessage: `${buyer.userId} don't have sufficient fund to purchase this location his wallet balance is : ${buyer.walletBalance}`,
                },
            };
            return response;
        }


        buyer.walletBalance = parseInt(buyer.walletBalance) - parseInt(record.transactionCost);
        seller.walletBalance = parseInt(seller.walletBalance) + parseInt(record.transactionCost);
        sellingLocation.placeOwner = buyer.userId;

        game.locations = gameLocations;
        game.players = gamePlayers;

        // return assetInterface.updateAsset(ctx, JSON.stringify(game));
        let updateStatus = await assetInterface.updateAsset(ctx, JSON.stringify(game));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = `Transfer Successful : Location ${sellingLocation.assetId} sold by ${seller.userId} to ${buyer.userId} for ${record.transactionCost}`;
            updateStatus.data.game = game;

        }
        return updateStatus;

    }

    async endGame(ctx, jsonInputArgs) { // gameId, userId
        console.info(
            '-----------------------VyaparContract:endGame---------------------------'
        );

        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-endGame-SYNTAX-400',
                    errorMessage: 'JSON input missing for endGame function.',
                },
            };
            return response;
        }

        let record;
        try {
            record = JSON.parse(jsonInputArgs);
        }
        catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-endGame-SYNTAX-400',
                    errorMessage: 'Invalid json Input for endGame function.',
                },
            };
            return response;


        }

        if (record.gameId === null || record.gameId === undefined || record.gameId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: 'BLANK',
                    errorCode: 'ce-endGame-SYNTAX-400',
                    errorMessage: 'Invalid gameId or gameId field missing.',
                },
            };
            return response;
        }

        if (record.userId === null || record.userId === undefined || record.userId.trim().length === 0) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-endGame-SYNTAX-400',
                    errorMessage: 'Invalid userId or userId field missing.',
                },
            };
            return response;
        }
        let gameData;
        try {
            gameData = await assetInterface.readAsset(ctx, JSON.stringify({ assetId: record.gameId }));
            // console.info('------back to endGame------------');
            // console.info(game);
        } catch (err) {
            console.error(err);
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-GameEnd-error-422',
                    errorMessage: 'Unable to read game details please check gameId...!',
                },
            };
            return response;
        }

        if (gameData.status === 'Error') {
            return gameData;
        }

        let game = gameData.data.assetData;

        if (game.closed !== undefined) {
            if (game.closed === true) {
                let response = {
                    status: 'Error',
                    data: {
                        gameId: record.gameId,
                        errorCode: 'ce-TransferGame-error-422',
                        errorMessage: 'Game is already closed...!',
                    },
                };
                return response;
            }
        }

        if (game.createdBy !== record.userId) {
            let response = {
                status: 'Error',
                data: {
                    gameId: record.gameId,
                    errorCode: 'ce-EndGame-error-422',
                    errorMessage: 'Only creator can close the game...!',
                },
            };
            return response;
        }

        // find winner
        let highestWalletBalance = 0;
        let winner = {};
        let gamePlayers = game.players;
        let gameLocations = game.locations;
        // console.info('----------------------End Game--------------------------');
        // console.info(gameLocations);
        // console.info(gamePlayers);
        gameLocations.forEach((location)=> {
            if (location.placeOwner !==undefined || location.placeOwner.trim().length!==0){
                // console.info(`location.placeOwner:${location.placeOwner}.`);
                let p = gamePlayers.find((player)=>player.userId===location.placeOwner);
                // console.info('p from gamePlayers.find():');
                // console.info(p);
                if(p!==undefined){
                    p.walletBalance= parseInt(p.walletBalance) + parseInt(location.placeCost);
                    // console.info(`User: ${p.userId} - walletBalance : ${p.walletBalance}`);
                }
            }
        });

        gamePlayers.forEach(player => {
            // console.info(`Before : ${player.walletBalance}`);
            // gameLocations.filter((location) => location.placeOwner === player.userId).forEach((l) => player.walletBalance = player.walletBalance + l.placeCost); ///ToDo
            // console.info(`Player.walletBalance : ${player.walletBalance} hightWalletBalance: ${highestWalletBalance}`);
            if (parseInt(player.walletBalance) > highestWalletBalance) {
                winner = player.userId;
                // console.info(winner);
                highestWalletBalance = parseInt(player.walletBalance);
            }
        });

        game.closed = true;
        game.winner = winner;
        // console.info(`game.winner : ${game.winner}`);
        // console.info(game.winner);

        // return assetInterface.updateAsset(ctx, JSON.stringify(game));
        let updateStatus = await assetInterface.updateAsset(ctx, JSON.stringify(game));
        if (updateStatus.status === 'Success') {
            updateStatus.data.transactionMessage = 'Game Closed Successfully';
            updateStatus.data.game = game;

        }
        return updateStatus;
    }
}
module.exports = vyaparContract;
