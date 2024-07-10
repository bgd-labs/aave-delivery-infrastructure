import "base.spec";
import "invariants.spec";


use invariant inv_TXid_maps_have_same_IDs;
use invariant inv_every_forwarded_TX_contains_registered_EV;
use invariant inv_TXnonce_less_than_curr_nonce;
use invariant nonce_correct;
use invariant max_nonceTX_is_valid;
    


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



