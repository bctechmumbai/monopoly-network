// const openssl = require('openssl-nodejs');
// const fs = require('fs');
const { BlockDecoder } = require("fabric-common");
// const { PassThrough } = require('stream');

// const commonProto = require('fabric-protos').common;
// const ccProto = require('fabric-protos').protos;
// const peerProto = require('fabric-protos').peer;

// const { SerializedIdentity } =require('fabric-protos').msp;
const { X509 } =require('jsrsasign');
// const x509 = require('x509');
// const { decode } = require('punycode');
// const { get } = require('http');





class transaction_library
{
    
    constructor(raw_transaction_details)
    {
       
        let raw_tr_details= BlockDecoder.decodeTransaction(raw_transaction_details);
        this.processedTransaction = raw_tr_details;
        this.decoded_transaction_details = this.get_transaction();
        
    }
    get_transaction()

    {   let transaction=this.processedTransaction
        let validationDef={
            0 : 'VALID',
            1: 'NIL_ENVELOPE',
            2: 'BAD_PAYLOAD',
            3: 'BAD_COMMON_HEADER',
            4: 'BAD_CREATOR_SIGNATURE',
            5: 'INVALID_ENDORSER_TRANSACTION',
            6: 'INVALID_CONFIG_TRANSACTION',
            7: 'UNSUPPORTED_TX_PAYLOAD',
            8: 'BAD_PROPOSAL_TXID',
            9: 'DUPLICATE_TXID',
            10: 'ENDORSEMENT_POLICY_FAILURE',
            11: 'MVCC_READ_CONFLICT',
            12: 'PHANTOM_READ_CONFLICT',
            13: 'UNKNOWN_TX_TYPE',
            14: 'TARGET_CHAIN_NOT_FOUND',
            15: 'MARSHAL_TX_ERROR',
            16: 'NIL_TXACTION',
            17: 'EXPIRED_CHAINCODE',
            18: 'CHAINCODE_VERSION_CONFLICT',
            19: 'BAD_HEADER_EXTENSION',
            20: 'BAD_CHANNEL_HEADER',
            21: 'BAD_RESPONSE_PAYLOAD',
            22: 'BAD_RWSET',
            23: 'ILLEGAL_WRITESET',
            24: 'INVALID_OTHER_REASON',
        }
    
        transaction.validationCode=validationDef[transaction.validationCode];
        transaction.transactionEnvelope.signature=transaction.transactionEnvelope.signature.toString('base64');
        transaction.transactionEnvelope.payload.header.channel_header.extension = transaction.transactionEnvelope.payload.header.channel_header.extension.toString();
        let pem = transaction.transactionEnvelope.payload.header.signature_header.creator.id_bytes.toString();
        let c1 = new X509();
        c1.readCertPEM(pem);
        transaction.transactionEnvelope.payload.header.signature_header.creator.id = c1.getSubjectString();
        transaction.transactionEnvelope.payload.header.signature_header.nonce=transaction.transactionEnvelope.payload.header.signature_header.nonce.toString('base64');
        transaction.transactionEnvelope.payload.header.signature_header.creator.id_bytes='';

        transaction.transactionEnvelope.payload.data.actions.forEach(action=>{
            let pem=action.header.creator.id_bytes.toString();
           
            let c2 = new X509();
            c2.readCertPEM(pem);
            action.header.creator.id= c2.getSubjectString();
            action.header.creator.id_bytes='';
            action.header.nonce=action.header.nonce.toString('base64');
            action.payload.chaincode_proposal_payload.input.chaincode_spec.input.args=action.payload.chaincode_proposal_payload.input.chaincode_spec.input.args.toString();
            action.payload.action.proposal_response_payload.proposal_hash= action.payload.action.proposal_response_payload.proposal_hash.toString('base64');

            let nssets=action.payload.action.proposal_response_payload.extension.results.ns_rwset
            nssets.forEach(nsset=>{
                let nssetwrites=nsset.rwset.writes;
                nssetwrites.forEach(write=>{
                    write.value=write.value.toString();
                });
            });

            action.payload.action.proposal_response_payload.extension.events.payload=action.payload.action.proposal_response_payload.extension.events.payload.toString();
            action.payload.action.proposal_response_payload.extension.response.payload=action.payload.action.proposal_response_payload.extension.response.payload.toString();


            let endorsements=action.payload.action.endorsements;
            endorsements.forEach(endorsmnt=>{
                let pem =endorsmnt.endorser.id_bytes.toString();
                let c3 = new X509();
                c3.readCertPEM(pem);
                endorsmnt.endorser.id= c3.getSubjectString();
                endorsmnt.endorser.id_bytes='';
                endorsmnt.signature=endorsmnt.signature.toString('base64');
            });

        });
        
        
        return transaction;
    }

    get_transaction_validation(){return this.decoded_transaction_details.validationCode;}
    get_transaction_envelope(){return this.decoded_transaction_details.transactionEnvelope;}
    get_transaction_envelope_signature(){return this.decoded_transaction_details.transactionEnvelope.signature;}
    get_transaction_envelope_payload(){return this.decoded_transaction_details.transactionEnvelope.payload;}
    get_transaction_envelope_payload_header(){return this.decoded_transaction_details.transactionEnvelope.payload.header;}
    get_transaction_envelope_payload_header_channelHeader(){return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header;}
    get_transaction_envelope_payload_header_channelHeader_type(){

        // Any of the following:
        // MESSAGE = 0; // Used for messages which are signed but opaque
        // CONFIG = 1; // Used for messages which express the channel config
        // CONFIG_UPDATE = 2; // Used for transactions which update the channel config
        // ENDORSER_TRANSACTION = 3; // Used by the SDK to submit endorser based transactions
        // ORDERER_TRANSACTION = 4; // Used internally by the orderer for management
        // DELIVER_SEEK_INFO = 5; // Used as the type for Envelope messages submitted to instruct the Deliver API to seek
        // CHAINCODE_PACKAGE = 6; // Used for packaging chaincode artifacts for install

        return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.type;
  
    }
    get_transaction_envelope_payload_header_channelHeader_version(){return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.version;}
    get_transaction_envelope_payload_header_channelHeader_timestamp(){
        //The local time when the message was created by the submitter
        return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.timestamp;
    }
    get_transaction_envelope_payload_header_channelHeader_channel_id(){return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.channel_id;}
    get_transaction_envelope_payload_header_channelHeader_tx_id(){
        //Unique identifier used to track the transaction throughout the proposal endorsement, ordering, validation and committing to the ledger
        return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.tx_id;
    }
    get_transaction_envelope_payload_header_channelHeader_epoch(){return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.epoch;}
    get_transaction_envelope_payload_header_signatureHeader(){return this.decoded_transaction_details.transactionEnvelope.payload.header.channel_header.signature_header;}
    get_transaction_envelope_payload_data(){return this.decoded_transaction_details.transactionEnvelope.payload.data;}
    get_transaction_envelope_payload_actions(){return this.decoded_transaction_details.transactionEnvelope.payload.data.actions;}
    get_transaction_envelope_payload_action(action_number){
        //It is the marshalled object of ChaincodeEndorsedAction struct that content the Proposal Hash and the Read/Write set used for the Chaincode in the transaction.
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number];
    }

    get_transaction_envelope_payload_action_header(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].header;
     }


    get_transaction_envelope_payload_action_payload(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload;

    }

    get_transaction_envelope_payload_action_payload_chaincode_proposal_payload(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.chaincode_proposal_payload;

    }

    get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_type(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.chaincode_proposal_payload.input.chaincode_spec.type;

    }
    get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_input(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.chaincode_proposal_payload.input.chaincode_spec.input.args;
    }


    get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_chaincode_id(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.chaincode_proposal_payload.input.chaincode_spec.chaincode_id;

    }
    get_transaction_envelope_payload_action_payload_chaincode_proposal_payload_input_chaincode_spec_timeout(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.chaincode_proposal_payload.input.chaincode_spec.timeout;

    }


    get_transaction_envelope_payload_action_payload_action(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action;

    }

    get_transaction_envelope_payload_action_payload_action_proposal_response_payload(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload;

    }

    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_proposal_hash(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.proposal_hash;

    }
    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension;

    }

    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.results;

    }

    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results_data_model(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.results.data_model;

    }
    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_results_ns_rwset(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.results.ns_rwset;
    }
    
    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_events(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.events;
    }
    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_response(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.response;
    }
    get_transaction_envelope_payload_action_payload_action_proposal_response_payload_extension_chaincode_id(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.proposal_response_payload.extension.chaincode_id;

    }


    get_transaction_envelope_payload_action_payload_action_endorsements(action_number){
        return this.decoded_transaction_details.transactionEnvelope.payload.data.actions[action_number].payload.action.endorsements;
    }

}

module.exports = transaction_library;
