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
    (bridgeTransaction_was_called()=> (get_last_nonceTX_sent()  < getCurrentTransactionNonce()));

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
   Rule 8: A new Envelope should always be registered.
         (equivalent to: envelop that is being sent must be registered.)

   Status: PASS
   ========================================================================= */
rule _08_sended_envelope_must_be_registered(method f)
    filtered {f -> f.selector!=sig:reset_harness_storage().selector}
{
    calldataarg args;
    env e;

    requireInvariant inv_TXid_maps_have_same_IDs();
    requireInvariant inv_every_forwarded_TX_contains_registered_EV();

    reset_harness_storage();
    
    f(e,args);

    assert (bridgeTransaction_was_called() => isEnvelopeRegistered(get_param_envelopeId()));
}


/*    ************ 
      Need to report a bug on the following. Important data is missing from the stack-trace   
      ***************
invariant inv_every_forwarded_TX_contains_registered_EV()
    forall bytes32 TXid. forall bytes32 ENid.
    (ENid==mirror_TXid_2_ENid[TXid] && mirror_forwardedTransactions[TXid]) => mirror_registeredEnvelopes[ENid]
    {
        preserved {
            requireInvariant inv_TXid_maps_have_same_IDs();
        }
    }
*/

    

    

/* ===========================================================================
   This rule is not part of the .md file.

   Status: PASS
   ========================================================================= */
rule every_sendedTX_must_be_registered(method f)
    filtered {f -> (f.selector != sig:reset_harness_storage().selector)}
{
    calldataarg args;
    env e;
    
    reset_harness_storage();
    
    f(e,args);

    assert (bridgeTransaction_was_called() => isTransactionForwarded(get_param_transactionId()));
}



