// /*
//  * SPDX-License-Identifier: Apache-2.0
//  */

'use strict';

const { ChaincodeStub, ClientIdentity } = require('fabric-shim');
const vyaparContract = require('../lib/vyaparContract');
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

describe('vyaparContract', () => {

    let contract ;
    let ctx;

    beforeEach(() => {
        contract = new vyaparContract();
        ctx = new TestContext();
        // ctx.stub.getState.withArgs('63981').resolves(Buffer.from('{"6398", "Joining", "(63)/2011/Pers-", "15/06/2011", "lahu_joining.pdf","encoded byte data of pdf file-lahu_joining.pdf","SHA256 Hash of pdf file-lahu_joining.pdf"}'));
        // ctx.stub.getState.withArgs('63982').resolves(Buffer.from('{"6398", "Transfer", "(01)/2014/Pers-", "15/07/2014","lahu_transfer_to_palghar.pdf", "encoded byte data of pdf file-lahu_transfer_to_palghar.pdf","SHA256 Hash of pdf file-lahu_transfer_to_palghar.pdf"}'));
    });

    describe('#createGame', () => {

        it('should return object for a new Game', async () => {
            let result= await contract.createGame(ctx);
            console.log(result);
        });

    });

    // describe('#createNicOrders', () => {

    //     it('should create a nic orders', async () => {
    //         await contract.createNicOrders(ctx,'6398', 'Transfer', '(02)/2018/Pers-', '10/08/2018', 'lahu_Transfer_mumbai.pdf','encoded byte data of pdf file - lahu_Transfer_mumbai.pdf', 'sha256 hash of pdf file - lahu_Transfer_mumbai.pdf');
    //         ctx.stub.putState.should.have.been.calledOnceWithExactly('63983', Buffer.from('{"orders":[{"empCode":"6398","orderType":"Transfer","orderNo":"(02)/2018/Pers-","OrderDate":"10/08/2018","OrderCopyName":"lahu_Transfer_mumbai.pdf","OrderCopybytes":"encoded byte data of pdf file - lahu_Transfer_mumbai.pdf","orderCopyHash":"sha256 hash of pdf file - lahu_Transfer_mumbai.pdf"}]}'));
    //     });

    //     it('should throw an error for a nic orders that already exists', async () => {
    //         await contract.createNicOrders(ctx, '63981', 'myvalue').should.be.rejectedWith(/The nic orders 63981 already exists/);
    //     });

    // });

    // describe('#readNicOrders', () => {

    //     it('should return a nic orders', async () => {
    //         await contract.readNicOrders(ctx, '63982').should.eventually.deep.equal('{"6398", "Transfer", "(01)/2014/Pers-", "15/07/2014","lahu_transfer_to_palghar.pdf", "encoded byte data of pdf file-lahu_transfer_to_palghar.pdf","SHA256 Hash of pdf file-lahu_transfer_to_palghar.pdf"}');
    //     });

    //     it('should throw an error for a nic orders that does not exist', async () => {
    //         await contract.readNicOrders(ctx, '63983').should.be.rejectedWith(/The nic orders 63983 does not exist/);
    //     });

    // });

    // describe('#updateNicOrders', () => {

    //     it('should update a nic orders', async () => {
    //         await contract.updateNicOrders(ctx, '63981', 'nic orders 63981 new value');
    //         ctx.stub.putState.should.have.been.calledOnceWithExactly('63981', Buffer.from('{"value":"nic orders 63981 new value"}'));
    //     });

    //     it('should throw an error for a nic orders that does not exist', async () => {
    //         await contract.updateNicOrders(ctx, '63983', 'nic orders 63983 new value').should.be.rejectedWith(/The nic orders 63983 does not exist/);
    //     });

    // });

    // describe('#deleteNicOrders', () => {

    //     it('should delete a nic orders', async () => {
    //         await contract.deleteNicOrders(ctx, '63981');
    //         ctx.stub.deleteState.should.have.been.calledOnceWithExactly('63981');
    //     });

    //     it('should throw an error for a nic orders that does not exist', async () => {
    //         await contract.deleteNicOrders(ctx, '63984').should.be.rejectedWith(/The nic orders 63984 does not exist/);
    //     });

    // });

});
