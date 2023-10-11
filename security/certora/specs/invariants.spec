import "base.spec";


/* The invariants of this file are used in several spec files */


/* ==============================================================================
   There are 2 maps in the solidity that involves the TX-ids:
   - in the design (CrossChainForwarder.sol):  mapping(bytes32 => bool) _forwardedTransactions;
     This simply remebers which IDs where already sent.
   - in the harness: mapping(bytes32 => uint) _TXid_2_TXnonceP1;
     A map from the ID of a TX, to its nonce PLUS 1. (So _TXid_2_TXnonceP1[id]!=0 if
     and only if this id was already sent.
   ==============================================================================*/
invariant inv_TXid_maps_have_same_IDs()
    forall bytes32 TXid.
    mirror_TXid_2_TXnonceP1[TXid] > 0 <=> mirror_forwardedTransactions[TXid];


/* ==============================================================================
   In the harness we maintain a map between a TX-id and its EN-id: _TXid_2_ENid.
   ==============================================================================*/
invariant inv_every_forwarded_TX_contains_registered_EV()
    forall bytes32 TXid.
    mirror_forwardedTransactions[TXid] => mirror_registeredEnvelopes[mirror_TXid_2_ENid[TXid]]
    {
        preserved {
            requireInvariant inv_TXid_maps_have_same_IDs();
        }
    }


/* ==============================================================================
   getCurrentTransactionNonce() returns the value of _currentTransactionNonce, a counter
   of the TX nonce used in the design to produce new TXs.
   ==============================================================================*/
invariant inv_TXnonce_less_than_curr_nonce()
    forall bytes32 TXid.
    mirror_forwardedTransactions[TXid] => to_mathint(mirror_TXid_2_TXnonceP1[TXid]) < getCurrentTransactionNonce()+1
    filtered {f -> f.selector!=sig:reset_harness_storage().selector && !f.isView}
    {
        preserved {
            requireInvariant inv_TXid_maps_have_same_IDs();
        }
    }


/* ==============================================================================
   ==============================================================================*/
invariant nonce_correct()
    (!bridgeTransaction_was_called()=>(get_last_nonceTX_sent()==0 && getCurrentTransactionNonce()==0))
    &&
    (bridgeTransaction_was_called()=>
     (get_last_nonceTX_sent()  < getCurrentTransactionNonce())
    )
    filtered {f -> f.selector!=sig:reset_harness_storage().selector && !f.isView}
    {
        preserved {
            requireInvariant inv_TXid_maps_have_same_IDs();
            requireInvariant inv_TXnonce_less_than_curr_nonce();
        }
    }


/* ==============================================================================
   we check several things:
   - The value of _max_TXnonce (from the harness) is greater or equal to all previously sent 
     TX nonces.
   - The max TX-nonce equal to _currentTransactionNonce - 1 (except of the first transaction
     when they are both 0).
   ==============================================================================*/
invariant max_nonceTX_is_valid()
    (forall bytes32 TXid. (mirror_forwardedTransactions[TXid] =>
                          (to_mathint(mirror_TXid_2_TXnonceP1[TXid]) <= mirror_max_TXnonce+1)
                          )
    )
    &&
    (getCurrentTransactionNonce()==0 => get_max_TXnonce()==0)
    &&
    (getCurrentTransactionNonce()!=0 => to_mathint(get_max_TXnonce())==getCurrentTransactionNonce()-1)
{
    preserved {
        requireInvariant inv_TXid_maps_have_same_IDs();
        requireInvariant inv_TXnonce_less_than_curr_nonce();
        requireInvariant nonce_correct();
    }
}

