/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

const ClientIdentity = require('fabric-shim').ClientIdentity;

class assetContract extends Contract {
    constructor() {
        super();
        this.TxId = '';
        this.TxUser = '';
        this.TxTm = '';
    }
    async beforeTransaction(ctx) {
        let cid = new ClientIdentity(ctx.stub);
        this.TxId = ctx.stub.getTxID();
        this.TxTm = new Date(ctx.stub.getTxTimestamp().seconds.low * 1000);
        this.TxUser = cid.getID();
    }
    async assetExists(ctx, assetId) {
        const buffer = await ctx.stub.getState(assetId);
        return !!buffer && buffer.length > 0;
    }
    async createAsset(ctx, jsonInputArgs) {
        // console.info(
        //     '-----------------------assetContract:createAsset---------------------------'
        // );
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-createAsset-SYNTAX-400',
                    errorMessage: 'JSON input missing for createAsset function.',
                },
            };
            return response;
        }

        let record;
        try{
            record = JSON.parse(jsonInputArgs);
        }
        catch(err){
            console.log(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-createAsset-SYNTAX-400',
                    errorMessage: 'Invalid json Input for createAsset function.',
                },
            };
            return response;
        }
        // console.log(`record Checking ${JSON.stringify(record)}`);
        // console.log(record);
        if (record.assetId === null || record.assetId === undefined || record.assetId.trim().length === 0) {

            let response={
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-createAsset-SYNTAX-400',
                    errorMessage: 'Invalid AssetId or AssetId field missing.',
                }
            };
            return response;
        }

        // console.log(`record Checking ${JSON.stringify(record)}`);
        // console.log(`record.assetId ${record.assetId}`);
        const exists = await this.assetExists(ctx, record.assetId);
        if (exists) {
            let response={
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-createAsset-syntax-error-400',
                    errorMessage: `The Asset with ID: ${record.assetId} already exists`,
                },
            };
            // console.log(JSON.stringify(response));
            return response;
        }
        // console.log('asset ID not already exists');
        let cid = new ClientIdentity(ctx.stub);
        let newAsset = {
            assetData: record,
            metaData: {
                createTxId: ctx.stub.getTxID(),
                createTxTm: new Date(ctx.stub.getTxTimestamp().seconds.low * 1000),
                createBy:  cid.getID(),
            },
        };
        try {
            // console.log(newAsset);
            const buffer = Buffer.from(JSON.stringify(newAsset));
            await ctx.stub.putState(record.assetId, buffer);
            let response = {
                status: 'Success',
                data: {
                    assetId: record.assetId,
                    operation: 'Create',
                    metaData: {
                        createTxId: newAsset.metaData.createTxId,
                        createTxTm: newAsset.metaData.createTxTm,
                        createBy: newAsset.metaData.createBy,
                    },
                },
            };
            // console.log(response);
            return response;
        } catch (err) {
            console.error(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-createAsset-store-error-422',
                    errorMessage: err.message,
                },
            };
            return response;
        }
    }
    async readAsset(ctx, jsonInputArgs) {
        // console.info(
        //     '-----------------------assetContract:readAsset---------------------------'
        // );
        // console.log(jsonInputArgs);
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-readAsset-SYNTAX-400',
                    errorMessage: 'JSON input missing for readAsset function.',
                },
            };
            return response;
        }
        let record;
        try{
            record = JSON.parse(jsonInputArgs);
        }
        catch(err){
            console.log(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-readAsset-SYNTAX-400',
                    errorMessage: 'Invalid json Input for readAsset function.',
                },
            };
            return response;
        }
        // console.log(record);
        if (record.assetId === null || record.assetId === undefined || record.assetId.trim().length === 0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-readAsset-SYNTAX-400',
                    errorMessage: 'Invalid AssetId or AssetId field missing.',
                },
            };
            return response;
        }

        // const exists = await this.assetExists(ctx, record.assetId);
        // if (!exists) {
        //     let response={
        //         status: 'Error',
        //         data: {
        //             assetId: record.assetId,
        //             errorCode: 'ce-readAsset-READ-error-422',
        //             errorMessage: `The Asset with ID: ${record.assetId} does not exists`,
        //         },
        //     };
        //     // console.log(JSON.stringify(response));
        //     return response;
        // }
        try {
            const buffer = await ctx.stub.getState(record.assetId);
            let response;
            if(!!buffer && buffer.length > 0)
            {
                response = {
                    status: 'Success',
                    data: { assetData: JSON.parse(buffer.toString()).assetData },
                };

            }
            else{
                response={
                    status: 'Error',
                    data: {
                        assetId: record.assetId,
                        errorCode: 'ce-readAsset-READ-error-422',
                        errorMessage: `The Asset with ID: ${record.assetId} does not exists`,
                    },
                };
            }
            // console.log(response);
            return response;
        } catch (err) {
            console.error(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-readAsset-READ-error-422',
                    errorMessage: err.message,
                },
            };
            return response;
        }
    }
    async updateAsset(ctx, jsonInputArgs) {
        // console.info(
        //     '-----------------------assetContract:updateAsset---------------------------'
        // );
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-updateAsset-SYNTAX-400',
                    errorMessage: 'JSON input missing for updateAsset function.',
                },
            };
            return response;
        }

        let record;
        try{
            record = JSON.parse(jsonInputArgs);
        }
        catch(err){
            console.log(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-updateAsset-SYNTAX-400',
                    errorMessage: 'Invalid json Input for updateAsset function.',
                },
            };
            return response;
        }
        // console.log(record);
        if (record.assetId === null || record.assetId === undefined || record.assetId.trim().length===0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-updateAsset-SYNTAX-400',
                    errorMessage: 'Invalid AssetId or AssetId field missing.',
                },
            };
            return response;
        }
        const exists = await this.assetExists(ctx, record.assetId);
        if (!exists) {

            let response={
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-updateAsset-UPDATE-error-422',
                    errorMessage: `The Asset with ID: ${record.assetId} does not exists`,
                },
            };
            return response;
        }
        try {
            const oldbuffer = await ctx.stub.getState(record.assetId);
            const oldrecord = JSON.parse(oldbuffer.toString());
            const oldrecord_assetData = oldrecord.assetData;

            for (const key in record) {
                oldrecord_assetData[key] = record[key];
            }
            let cid = new ClientIdentity(ctx.stub);
            let metaData = {
                createTxId: oldrecord.metaData.createTxId,
                createTxTm: oldrecord.metaData.createTxTm,
                createBy: oldrecord.metaData.createBy,
                updateTxId: ctx.stub.getTxID(),
                updateTxTm:  new Date(ctx.stub.getTxTimestamp().seconds.low * 1000),
                updateBy: cid.getID(),
            };

            let updatedAsset = { assetData: oldrecord_assetData, metaData: metaData };
            // console.log(JSON.stringify(asset));
            const buffer = Buffer.from(JSON.stringify(updatedAsset));
            await ctx.stub.putState(record.assetId, buffer);
            let response = {
                status: 'Success',
                data: {
                    assetId: record.assetId,
                    operation: 'Update',
                    metadata: metaData,
                },
            };
            // console.log(response);
            return response;
        } catch (err) {
            console.error(err);
            let response={
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-updateAsset-UPDATE-error-422',
                    errorMessage: err.message,
                },
            };
            return response;
        }
    }
    async deleteAsset(ctx, jsonInputArgs){
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            return {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-deleteAsset-SYNTAX-400',
                    errorMessage: 'JSON input missing for deleteAsset function.',
                },
            };
        }
        let record;
        try{
            record = JSON.parse(jsonInputArgs);
        }
        catch(err){
            console.log(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-deleteAsset-SYNTAX-400',
                    errorMessage: 'Invalid json Input for deleteAsset function.',
                },
            };
            return response;
        }
        if (record.assetId === null || record.assetId === undefined || record.assetId.trim().length === 0) {
            return {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-deleteAsset-SYNTAX-400',
                    errorMessage: 'Invalid AssetId or AssetId field missing.',
                },
            };
        }
        const exists = await this.assetExists(ctx, record.assetId);
        if (!exists) {

            let response={
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-deleteAsset-error-422',
                    errorMessage: `The Asset with ID: ${record.assetId} does not exists`,
                },
            };
            return response;
        }
        try{
            await ctx.stub.deleteState(record.assetId);
            let response = {
                status: 'Success',
                data: {
                    assetId: record.assetId,
                    operation: 'Delete'
                },
            };
            // console.log(response);
            return response;
        }
        catch(err)
        {
            console.error(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'ce-deleteAsset-error-422',
                    errorMessage: err.message,
                },
            };
            return response;

        }
    }

    async readAssetsByQuery(ctx, jsonInputArgs) {

        // console.info(
        //     '-----------------------assetContract:readAssetsByQuery---------------------------'
        // );

        // console.info(jsonInputArgs);
        // jsonInputArgs=null;
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length===0) {
            let response= {
                status: 'Error',
                data: {
                    assetQuery: 'BLANK',
                    errorCode: 'ce-readAssetsByQuery-SYNTAX-400',
                    errorMessage: 'JSON input missing for readAssetsByQuery function.',
                },
            };
            return response;
        }

        try {
            let queryResult = await this.GetQueryResultForQueryString(ctx, jsonInputArgs);
            if(queryResult.status==='Error'){
                return queryResult;
            }

            let response= {
                status: 'Success',
                data: queryResult,
            };
            return response;

        } catch (err) {
            console.error(err);
            return {
                status: 'Error',
                data: {
                    assetQuery:jsonInputArgs,
                    errorCode: 'ce-readAssetsByQuery-error-422',
                    errorMessage: err.message,
                },
            };
        }
    }

    async GetQueryResultForQueryString(ctx, queryString) {
        // console.info(
        //     '-----------------------assetContract:GetQueryResultForQueryString---------------------------'
        // );
        // console.log(queryString);
        try {
            // console.log('GetQueryResultForQueryString :');
            // console.log('Query String');
            // console.log(queryString);
            let resultsIterator = await ctx.stub.getQueryResult(queryString);
            // console.log('Result of ctx.stub.getQueryResult:');
            // console.log(resultsIterator);
            if(resultsIterator===undefined){
                let response= {
                    status: 'Error',
                    data: {
                        assetQuery: queryString,
                        errorCode: 'ce-GetQueryResultForQueryString-error-400',
                        errorMessage: 'No data found for given query',
                    },
                };
                return response;
            }

            let results = await this.getAllResults(resultsIterator, false);
            if(results===undefined){
                let response= {
                    status: 'Error',
                    data: {
                        errorCode: 'ce-GetQueryResultForQueryString-error-400',
                        errorMessage: 'Unable to extract result set from iterator.',
                    },
                };
                return response;
            }
            // console.log('Result of this.getAllResults:');
            // console.log(results);
            return results;

        } catch (err) {
            console.error(err);
            return {
                status: 'Error',
                data: {
                    assetQuery: JSON.stringify(queryString),
                    errorCode: 'ce-GetQueryResultForQueryString-error-422',
                    errorMessage: err.message,
                },
            };
        }
    }

    async getAssetHistory(ctx, jsonInputArgs) {
        // console.info(
        //     '-----------------------assetContract:getAssetHistory---------------------------'
        // );
        if (jsonInputArgs === null || jsonInputArgs === undefined || jsonInputArgs.trim().length === 0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-getAssetHistory-SYNTAX-400',
                    errorMessage: 'JSON input missing for getAssetHistory function.',
                },
            };
            return response;
        }
        let record;
        try{
            record = JSON.parse(jsonInputArgs);
        }
        catch(err){
            console.log(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-getAssetHistory-SYNTAX-400',
                    errorMessage: 'Invalid json Input for getAssetHistory function.',
                },
            };
            return response;
        }

        if (record.assetId === null || record.assetId === undefined || record.assetId.trim().length===0) {
            let response= {
                status: 'Error',
                data: {
                    assetId: 'BLANK',
                    errorCode: 'ce-getAssetHistory-SYNTAX-400',
                    errorMessage: 'Invalid AssetId or AssetId field missing.',
                },
            };
            return response;
        }

        // const exists = await this.assetExists(ctx, record.assetId);

        // if (!exists) {

        //     let response={
        //         status: 'Error',
        //         data: {
        //             assetId: record.assetId,
        //             errorCode: 'ce-getAssetHistory-UPDATE-error-422',
        //             errorMessage: `The Asset with ID: ${record.assetId} does not exists`,
        //         },
        //     };
        //     return response;
        // }

        // console.log('History for  ...' + record.assetId);
        let resultsIterator;
        try {
            resultsIterator = await ctx.stub.getHistoryForKey(record.assetId);
        } catch (err) {
            console.error(err);
            let response= {
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'CE-getCaseHistory-process-422',
                    errorMessage: 'Unable to read history for given assetId.',
                },
            };
            return response;
        }
        if (resultsIterator === null || resultsIterator === undefined)
        {
            let response={
                status: 'Error',
                data: {
                    assetId: record.assetId,
                    errorCode: 'CE-getCaseHistory-process-422',
                    errorMessage: 'Unable to get History',
                },
            };
            return response;
        }
        let results = await this.getAllResults(resultsIterator, true);
        let response= {
            status: 'Success',
            data: results,
        };
        return response;
    }

    async getAllResults(iterator, isHistory) {
        // console.info(
        //     '-----------------------assetContract:getAllResults--------------------------'
        // );
        // console.log(`iterator ${iterator}`);
        // console.log(`isHistory ${isHistory}`);
        let allResults = [];
        let res = await iterator.next();
        // console.log(`res.done ${res.done}`);
        while (!res.done) {
            // console.log(`res.value ${res.value}`);
            // console.log(`res.value.value.toString() ${res.value.value.toString()}`);
            if (res.value && res.value.value.toString()) {
                let jsonRes = {};
                // console.log(res.value.value.toString('utf8'));
                if (isHistory && isHistory === true) {
                    jsonRes.TxId = res.value.tx_id;
                    jsonRes.Timestamp = res.value.timestamp;
                    try {
                        jsonRes = JSON.parse(
                            res.value.value.toString('utf8')
                        );
                    } catch (err) {
                        console.log(err);
                        jsonRes= res.value.value.toString('utf8');
                    }
                } else {
                    // console.log(`jsonRes.Key ${jsonRes.Key}`);
                    // jsonRes.Key = res.value.key;
                    try {
                        // jsonRes.Record = JSON.parse(
                        //     res.value.value.toString('utf8')
                        jsonRes = JSON.parse(res.value.value.toString('utf8')
                        );
                    } catch (err) {
                        console.log(err);
                        // jsonRes.Record = res.value.value.toString('utf8');
                        jsonRes = res.value.value.toString('utf8');
                    }
                }
                allResults.push(jsonRes);
            }
            res = await iterator.next();
        }
        iterator.close();
        // console.log(`allResults ${allResults}`);
        return allResults;
    }


}
module.exports = assetContract;
