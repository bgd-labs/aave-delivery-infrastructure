import "base.spec";
//import "invariants.spec";

// ========================================================             
// ========================================================             
// The following invariants are proved in the file invariants.spec
// ========================================================             
// ========================================================             

invariant inv_TXid_maps_have_same_IDs()
    forall bytes32 TXid.
    mirror_TXid_2_TXnonceP1[TXid] > 0 <=> mirror_forwardedTransactions[TXid];

//**********************************************
invariant inv_every_forwarded_TX_contains_registered_EV()
    forall bytes32 TXid.
    mirror_forwardedTransactions[TXid] => mirror_registeredEnvelopes[mirror_TXid_2_ENid[TXid]];
    
//**********************************************
invariant inv_TXnonce_less_than_curr_nonce()
    forall bytes32 TXid.
    mirror_forwardedTransactions[TXid] => to_mathint(mirror_TXid_2_TXnonceP1[TXid]) < getCurrentTransactionNonce()+1;

//**********************************************
invariant nonce_correct()
    (!bridgeTransaction_was_called()=>(get_last_nonceTX_sent()==0 && getCurrentTransactionNonce()==0))
    &&
    (bridgeTransaction_was_called()=> (get_last_nonceTX_sent()  < getCurrentTransactionNonce()) );

//**********************************************
invariant max_nonceTX_is_valid()
    (forall bytes32 TXid. (mirror_forwardedTransactions[TXid] =>
                          (to_mathint(mirror_TXid_2_TXnonceP1[TXid]) <= mirror_max_TXnonce+1))  )
    &&
    (getCurrentTransactionNonce()==0 => get_max_TXnonce()==0)
    &&
    (getCurrentTransactionNonce()!=0 => to_mathint(get_max_TXnonce())==getCurrentTransactionNonce()-1);

// ========================================================             
// ========================================================             
// END OF INVARIANTS
// ========================================================            
// ========================================================             



/* ===========================================================================
   Rule 12:  An Envelope retry should be on a new Transaction.

   Status: PASS.
   Remark: We actually check that a retried-envelope is sended by a transaction with 
           nonce different (bigger) from all previous ones.
   ========================================================================= */
rule _12_envelope_retry_must_be_in_new_transaction() {
    env e;

    uint max_TXnonce_before = get_max_TXnonce();
    bool this_is_the_first_transaction = !bridgeTransaction_was_called();

    requireInvariant max_nonceTX_is_valid();
    requireInvariant nonce_correct();

    CrossChainForwarderHarness.Envelope envelope;
    uint256 gasLimit;
    retryEnvelope(e,envelope,gasLimit);

    uint nonceTX = get_last_nonceTX_sent();
    assert nonceTX > max_TXnonce_before || this_is_the_first_transaction;
}

    
