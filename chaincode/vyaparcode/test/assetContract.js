/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { ChaincodeStub, ClientIdentity } = require('fabric-shim');
const assetContract = require('../lib/assetContract');
const winston = require('winston');

const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const sinon = require('sinon');
const sinonChai = require('sinon-chai');

chai.should();
chai.use(chaiAsPromised);
chai.use(sinonChai);

class TestContext {

    constructor() {
        this.stub = sinon.createStubInstance(ChaincodeStub);
        this.clientIdentity = sinon.createStubInstance(ClientIdentity);
        this.logger = {
            getLogger: sinon.stub().returns(sinon.createStubInstance(winston.createLogger().constructor)),
            setLevel: sinon.stub(),
        };
    }

}

describe('assetContract', () => {

    let contract;
    let ctx;
    beforeEach(() => {
        contract = new assetContract();
        ctx = new TestContext();
        ctx.stub.getState.withArgs('LOC-01').resolves(Buffer.from('{"assetData": {"assetId": "LOC-01", "assetType": "LOC", "placeId": 1, "placeName": "START", "placeCost": 0, "placeRent": 0, "placeType": "S"}, "metaData":{ "createTxId":"" , "createTxTm":"", "createBy":"" }}'));
        ctx.stub.getState.withArgs('LOC-02').resolves(Buffer.from('{"assetData": {"assetId": "LOC-02", "assetType": "LOC", "placeId": 2, "placeName": "Mumbai", "placeCost": 8500, "placeRent": 500, "placeColor": "Pink", "placeType": "L"}, "metaData":{ "createTxId": "", "createTxTm": "", "createBy": ""  }}'));
        ctx.stub.getState.withArgs('LOC-03').resolves(Buffer.from('{"assetData": {"assetId": "LOC-03", "assetType": "LOC", "placeId": 3, "placeName": "Agra", "placeCost": 2500, "placeRent": 250, "placeColor": "Blue", "placeType": "L"}, "metaData":{ "createTxId": "", "createTxTm": "", "createBy": ""  }}'));
        ctx.stub.getQueryResult.withArgs('{"selector": { "assetData": { "assetType": "LOC" }}}').yields(JSON.stringify([
            {
                assetData: {
                    assetId: 'LOC-01',
                    assetType: 'LOC',
                    placeId: 1,
                    placeName: 'START',
                    placeCost: 0,
                    placeRent: 0,
                    placeType: 'S'
                },
                metaData: { createTxId: '', createTxTm: '', createBy: '' }
            },
            {
                assetData: {
                    assetId: 'LOC-02',
                    assetType: 'LOC',
                    placeId: 2,
                    placeName: 'Mumbai',
                    placeCost: 8500,
                    placeRent: 500,
                    placeColor: 'Pink',
                    placeType: 'L'
                },
                metaData: { createTxId: '', createTxTm: '', createBy: '' }
            },
            {
                assetData: {
                    assetId: 'LOC-03',
                    assetType: 'LOC',
                    placeId: 3,
                    placeName: 'Agra',
                    placeCost: 2500,
                    placeRent: 250,
                    placeColor: 'Blue',
                    placeType: 'L'
                },
                metaData: { createTxId: '', createTxTm: '', createBy: '' }
            }
        ]));
    });

    describe('#assetExists', () => {

        it('should return true for a asset ', async () => {
            await contract.assetExists(ctx, 'LOC-01').should.eventually.be.true;
        });

        it('should return false for a asset that does not exists', async () => {
            await contract.assetExists(ctx, 'LOC-04').should.eventually.be.false;
        });

    });


    describe('#createAsset', () => {

        it('should return Success and create a asset', async () => {
            await contract.createAsset(ctx, '{"assetId": "LOC-04", "assetType": "LOC", "placeId": 4, "placeName": "Motorboat", "placeCost": 5500, "placeRent": 300, "placeColor": "Brown", "placeType": "S"}').should.eventually.deep.equal({ status: 'Success', data: { assetId: 'LOC-04', operation: 'Create', metaData: { createTxId: '', createTxTm: '', createBy: '' }}});
            ctx.stub.putState.should.have.been.calledOnceWithExactly('LOC-04', Buffer.from('{"assetData":{"assetId":"LOC-04","assetType":"LOC","placeId":4,"placeName":"Motorboat","placeCost":5500,"placeRent":300,"placeColor":"Brown","placeType":"S"},"metaData":{"createTxId":"","createTxTm":"","createBy":""}}'));
        });

        it('should return an error object for a asset that already exists', async () => {
            await contract.createAsset(ctx, '{ "assetId": "LOC-01" }').should.eventually.deep.equal({status: 'Error',data: {assetId: 'LOC-01',errorCode: 'ce-createAsset-syntax-error-400',errorMessage: 'The Asset with ID: LOC-01 already exists'}});
        });

        it('should return an error object as asset ID key is missing in Input', async () => {
            await contract.createAsset(ctx, '{ "assetType": "LOC" }').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-createAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return an error object as asset ID value is missing in Input', async () => {
            await contract.createAsset(ctx, '{ "assetId": "    " }').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-createAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return an error object as no json Input', async () => {
            await contract.createAsset(ctx, '').should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK', errorCode: 'ce-createAsset-SYNTAX-400', errorMessage: 'Invalid json Input for createAsset function.',}});
        });
        it('should return an error object with error Invalid Query input or query missing ', async () => {
            await contract.createAsset(ctx,).should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-createAsset-SYNTAX-400', errorMessage: 'Invalid json Input for createAsset function.'}});
        });


    });

    describe('#readAsset', () => {

        it('should return return Success and asset object', async () => {
            await contract.readAsset(ctx, '{"assetId": "LOC-01"}').should.eventually.deep.equal({status:'Success', data: {assetData:{assetId: 'LOC-01', assetType: 'LOC', placeId: 1, placeName: 'START', placeCost: 0, placeRent: 0, placeType: 'S'}}});
        });

        it('should throw an error for asset that does not exists', async () => {
            await contract.readAsset(ctx, '{"assetId": "LOC-05"}').should.eventually.deep.equal({status:'Error', data: {assetId: 'LOC-05', errorCode: 'ce-readAsset-READ-error-422', errorMessage: 'The Asset with ID: LOC-05 does not exists'}});
        });

        it('should return an error object as asset ID key is missing in Input', async () => {
            await contract.readAsset(ctx, '{ "assetType": "LOC" }').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-readAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return an error object as asset ID value is missing in Input', async () => {
            await contract.readAsset(ctx, '{ "assetId": " " }').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-readAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });
        it('should return an error object as no json Input', async () => {
            await contract.readAsset(ctx, '').should.eventually.deep.equal({ status: 'Error', data: {  assetId: 'BLANK', errorCode: 'ce-readAsset-SYNTAX-400', errorMessage: 'Invalid json Input for readAsset function.',}});
        });
        it('should return Error with error Invalid Query input or query missing ', async () => {
            await contract.readAsset(ctx,).should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK',  errorCode: 'ce-readAsset-SYNTAX-400', errorMessage: 'Invalid json Input for readAsset function.'}});
        });

    });

    describe('#updateAsset', () => {

        it('should throw an error for asset that does not exists', async () => {
            await contract.updateAsset(ctx, '{"assetId": "LOC-05"}').should.eventually.deep.equal({status:'Error', data: {assetId: 'LOC-05', errorCode: 'ce-updateAsset-UPDATE-error-422', errorMessage: 'The Asset with ID: LOC-05 does not exists'}});
        });

        it('should return an error object as asset ID key is missing in Input', async () => {
            await contract.updateAsset(ctx, '{ "assetType": "LOC" }').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK',  errorCode: 'ce-updateAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return an error object as asset ID value is missing in Input', async () => {
            await contract.updateAsset(ctx, '{ "assetId": " " }').should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK',  errorCode: 'ce-updateAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });
        it('should return an error object as blank json Input', async () => {
            await contract.updateAsset(ctx, '').should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK',  errorCode: 'ce-updateAsset-SYNTAX-400', errorMessage: 'Invalid json Input for updateAsset function.',}});
        });
        it('should return an error object as no json Input', async () => {
            await contract.updateAsset(ctx,).should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK',  errorCode: 'ce-updateAsset-SYNTAX-400', errorMessage: 'Invalid json Input for updateAsset function.',}});
        });
        it('should return Success and update asset with addition of new key value pair', async () => {
            await contract.updateAsset(ctx, '{ "assetId": "LOC-01", "Owner": "Lahu Waghmare" }').should.eventually.deep.equal({ status: 'Success', data: { assetId: 'LOC-01', operation: 'Update', metadata: { updateTxId: '', updateTxTm: '', updateBy: '' }}});
            ctx.stub.putState.should.have.been.calledOnceWithExactly('LOC-01', Buffer.from('{"assetData":{"assetId":"LOC-01","assetType":"LOC","placeId":1,"placeName":"START","placeCost":0,"placeRent":0,"placeType":"S","Owner":"Lahu Waghmare"},"metaData":{"createTxId":"","createTxTm":"","createBy":"","updateTxId":"","updateTxTm":"","updateBy":""}}'));
        });

        it('should return Success and update asset with modified value of existing key', async () => {
            await contract.updateAsset(ctx, '{ "assetId": "LOC-01", "Owner": "Lahu Waghmare" }').should.eventually.deep.equal({ status: 'Success', data: { assetId: 'LOC-01', operation: 'Update', metadata: { updateTxId: '', updateTxTm: '', updateBy: '' }}});
            ctx.stub.putState.should.have.been.calledOnceWithExactly('LOC-01', Buffer.from('{"assetData":{"assetId":"LOC-01","assetType":"LOC","placeId":1,"placeName":"START","placeCost":0,"placeRent":0,"placeType":"S","Owner":"Lahu Waghmare"},"metaData":{"createTxId":"","createTxTm":"","createBy":"","updateTxId":"","updateTxTm":"","updateBy":""}}'));
        });


    });
    describe('#deleteAsset', () => {
        it('should return Error with error Invalid Json input or JSON missing ', async () => {
            await contract.deleteAsset(ctx,).should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK', errorCode: 'ce-deleteAsset-SYNTAX-400', errorMessage: 'Invalid json Input for deleteAsset function.'}});
        });
        it('should return Error with error Invalid Query input or query missing ', async () => {
            await contract.deleteAsset(ctx, '').should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK', errorCode: 'ce-deleteAsset-SYNTAX-400', errorMessage: 'Invalid json Input for deleteAsset function.'}});
        });

        it('should throw an error for asset that does not exists', async () => {
            await contract.deleteAsset(ctx, '{"assetId": "LOC-05"}').should.eventually.deep.equal({status:'Error', data: {assetId: 'LOC-05', errorCode: 'ce-deleteAsset-error-422', errorMessage: 'The Asset with ID: LOC-05 does not exists'}});
        });

        it('should return an error object as asset ID key is missing in Input', async () => {
            await contract.deleteAsset(ctx, '{ "assetType": "LOC" }').should.eventually.deep.equal({ status: 'Error', data: {assetId: 'BLANK', errorCode: 'ce-deleteAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return an error object as asset ID value is missing in Input', async () => {
            await contract.deleteAsset(ctx, '{ "assetId": " "}').should.eventually.deep.equal({ status: 'Error', data: { assetId: 'BLANK',errorCode: 'ce-deleteAsset-SYNTAX-400', errorMessage: 'Invalid AssetId or AssetId field missing.',}});
        });

        it('should return success response delete asset', async () => {
            await contract.deleteAsset(ctx, '{ "assetId": "LOC-01"}').should.eventually.deep.equal({ status: 'Success', data: {assetId:'LOC-01' , operation: 'Delete'}});
            ctx.stub.deleteState.should.have.been.calledOnceWithExactly('LOC-01');
            // console.log(x);
        });




    });

    describe('#readAssetsByQuery', () => {
        it('should return Error with error Invalid Query input or query missing ', async () => {
            await contract.readAssetsByQuery(ctx,).should.eventually.deep.equal({ status: 'Error', data: { assetQuery: 'BLANK', errorCode: 'ce-readAssetsByQuery-SYNTAX-400', errorMessage: 'Invalid json Input for readAssetsByQuery function.'}});
        });
        it('should return Error with error Invalid Query input or query missing ', async () => {
            await contract.readAssetsByQuery(ctx, '').should.eventually.deep.equal({ status: 'Error', data: { assetQuery: 'BLANK', errorCode: 'ce-readAssetsByQuery-SYNTAX-400', errorMessage: 'Invalid json Input for readAssetsByQuery function.'}});
        });

        it('should return Error with error No Data Found', async () => {
            await contract.readAssetsByQuery(ctx, '{"selector": { "assetData": { "assetType":{"$eq": ""} }}}').should.eventually.deep.equal({ status: 'Error',  data: {assetQuery: '{"selector": { "assetData": { "assetType":{"$eq": ""} }}}', errorCode: 'ce-GetQueryResultForQueryString-error-400', errorMessage: 'No data found for given query'}});
        });
        /// TODO
        // Test for successful iterator result
        // it('should return array of assets having assetType as LOC', async () => {
        // let x= await contract.readAssetsByQuery(ctx, '{"selector": { "assetData": { "assetType": "LOC" }}}');
        // console.log(x);
        // });

    });

});
