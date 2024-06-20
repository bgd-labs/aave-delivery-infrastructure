import "base.spec";
import "invariants.spec";

use invariant inv_TXid_maps_have_same_IDs;
use invariant inv_every_forwarded_TX_contains_registered_EV;
use invariant inv_TXnonce_less_than_curr_nonce;
use invariant nonce_correct;
use invariant max_nonceTX_is_valid;



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

    
