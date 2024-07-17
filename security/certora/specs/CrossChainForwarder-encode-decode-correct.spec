
/* ===========================================================================
   In this file we Check the following:
   If we encode and then decode a Transaction struct we get back the original transaction.
   ========================================================================= */

methods {
    function get_envelope_from_TX(CrossChainForwarderHarnessED.Transaction transaction)
        external returns (CrossChainForwarderHarnessED.Envelope) envfree;
    function encode_EN(CrossChainForwarderHarnessED.Envelope envelope)
        external returns (bytes) envfree;
    function compare_bytes(bytes x, bytes y) external returns (bool) envfree;
    function get_bytes_X() external returns (bytes memory) envfree;
    function create_real_TX(uint256 nonce,
                            address origin,
                            address destination,
                            uint256 originChainId,
                            uint256 destinationChainId,
                            bytes message,
                            uint256 TXnonce) external returns (CrossChainForwarderHarnessED.Transaction memory) envfree;
    

    function get_last_encodedTX() external returns (bytes) envfree;
    function get_TX_from_encodedTX(bytes encodedTX) external returns (CrossChainForwarderHarnessED.Transaction) envfree;
    function bridgeTransaction_was_called() external returns (bool) envfree;
    function reset_harness_storage() external envfree;
}



/* ===========================================================================
   Rule: decode(encode(TX)) == TX
   We check that the above is correct for every TX that was created by the folowing steps:
   1. Create an Envelope, EN.
   2. encode EN by calling to EN.encode();
   3. create a transaction (TX) with the encoded envelope fron step 2.

   Status: PASS
   ========================================================================= */
rule encode_decode_well_formed_TX() {
    uint256 nonce;
    address origin;
    address destination;
    uint256 originChainId;
    uint256 destinationChainId;
    bytes message;
    uint256 TXnonce;

    //require message.length == 1;
    CrossChainForwarderHarnessED.Transaction tran =
        create_real_TX(nonce,origin,destination,originChainId,destinationChainId,message,TXnonce);

    //assert tran.encodedEnvelope.length==288;
    
    CrossChainForwarderHarnessED.Envelope toReturn = get_envelope_from_TX(tran);
    
    bytes by = encode_EN(toReturn);   
    assert compare_bytes(by, tran.encodedEnvelope) ;
}


/* ===========================================================================
   Rule: decode(encode(TX)) == TX for arbitrary TX.

   Status: FAIL.
   according to John this failure is OK.
   ========================================================================= */
rule encode_decode_arbitrary_TX() {
    CrossChainForwarderHarnessED.Transaction tran;
    CrossChainForwarderHarnessED.Envelope toReturn = get_envelope_from_TX(tran);

    require tran.encodedEnvelope.length==288;
    require toReturn.message.length==1;

    bytes by = encode_EN(toReturn);   
    assert compare_bytes(by, tran.encodedEnvelope) ;
}


function encode_decode_correct(bytes encodedTX)
    returns bool {
    CrossChainForwarderHarnessED.Transaction tran = get_TX_from_encodedTX(encodedTX);
    CrossChainForwarderHarnessED.Envelope toReturn = get_envelope_from_TX(tran);

    bytes by = encode_EN(toReturn);   
    return compare_bytes(by, tran.encodedEnvelope) ;
}


/* ===========================================================================
   Rule: decode(encode(TX)) == TX for every TX that is outputed by the Forwarder

   Status: TIMEOUT. opened ticket: https://certora.atlassian.net/browse/CERT-4352
   ========================================================================= */
rule encode_decode_for_outputed_TX(method f)
    filtered {f -> f.selector!=sig:reset_harness_storage().selector}
{
    calldataarg args;
    env e;

    reset_harness_storage();
    
    f(e,args);

    assert (bridgeTransaction_was_called() => encode_decode_correct(get_last_encodedTX()));
}



rule test_bytes() {
    bytes b = get_bytes_X();
    assert (b.length == 2);
}
