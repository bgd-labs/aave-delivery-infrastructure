import "methods.spec";
import "allowedBridgeAdaptersAddressSet.spec";

using BaseReceiverPortalDummy as _BaseReceiverPortalDummy;

methods{

  function getEnvelopeState(EnvelopeUtils.Envelope) external returns (ICrossChainReceiver.EnvelopeState) envfree;
  function getEnvelopeState(bytes32) external returns (ICrossChainReceiver.EnvelopeState) envfree;
  function isReceiverBridgeAdapterAllowed(address,uint256) external returns (bool) envfree;
  function getReceiverBridgeAdaptersByChain(uint256) external returns (address[]) envfree;
  function getConfigurationByChain(uint256) external returns (ICrossChainReceiver.ReceiverConfiguration) envfree;
  function getTransactionState(bytes32) external returns (ICrossChainReceiver.TransactionStateWithoutAdapters) envfree;
  function getConfigurationByChain(uint256) external returns (ICrossChainReceiver.ReceiverConfiguration) envfree;
  function isTransactionReceivedByAdapter(bytes32,address) external returns (bool) envfree;


  //from harness
  function getEncodedTransactionId(bytes) external returns (bytes32) envfree;
  function getEnvelopeId(EnvelopeUtils.Envelope) external returns (bytes32) envfree;
  function getEnvelopeId(bytes) external returns (bytes32) envfree;
  function getEnvelope(bytes) external returns (EnvelopeUtils.Envelope memory) envfree;
  function compare(bytes,bytes) external returns (bool) envfree;
  function compare(bytes32,bytes32) external returns (bool) envfree;
  function compare(EnvelopeUtils.Envelope,EnvelopeUtils.Envelope) external returns (bool) envfree;
  function getConfirmations(bytes32) external returns (uint8) envfree;
	function getFirstBridgedAt(bytes32) external returns (uint120) envfree;
  function _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter() external returns (uint256) envfree;
  function _BaseReceiverPortalDummy.get_receive_cross_chain_message_counter
            (address,uint256,bytes) external returns (uint256) envfree;

  //
  // Summarizations
  //
  //Helper function: decides nondeterministically whteher to revert
  function  _.receiveCrossChainMessage_reverts() internal => NONDET;
  
  // The internal recieve function that receives a message from a bridge adapter.
  // Declared in IBaseReceiverPortal.sol, implemented in harness/BaseReceiverPortalDummy.sol
  function _.receiveCrossChainMessage(address,uint256,bytes) external => DISPATCHER(true);
 
}


// import invariants from AddressSet spec
use invariant addressSetInvariant;
use invariant setInvariant;
use rule set_size_eq_max_uint160_witness;


// CVL shortcut functions
function getRequiredConfirmation(uint256 chainId) returns uint8
{
  ICrossChainReceiver.ReceiverConfiguration config_before = getConfigurationByChain(chainId);
  return config_before.requiredConfirmation;
}


function get_confirmations(bytes32 transactionId) returns uint8
{
  ICrossChainReceiver.TransactionStateWithoutAdapters state_before = getTransactionState(transactionId);
  return state_before.confirmations;
}



//
// Properties of docs/properties.md
//

//1. A Transaction can only be received from authorized bridge adapters.
// Verify the modifier of docs/properties.md()
rule transaction_received_only_from_authorized_bridge_adapter
{
  env e;
  bytes encodedTransaction;
  uint256 originChainId;

  receiveCrossChainMessage(e, encodedTransaction, originChainId);
  assert isReceiverBridgeAdapterAllowed(e.msg.sender, originChainId);
}


//2. Only the Owner can set the receiver's bridge adapters.
rule only_owner_can_change_bridge_adapters(method f) filtered { f-> !f.isView }
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  f(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  assert e.msg.sender != owner() => is_allowed_before == is_allowed_after;
}

// Generate a witness of the previous rule
rule only_owner_can_change_bridge_adapters_witness_consequent(method f) 
filtered {f -> f.selector == sig:allowReceiverBridgeAdapters(ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]).selector 
  || f.selector == sig:disallowReceiverBridgeAdapters(ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]) .selector}
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  f(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  satisfy is_allowed_before != is_allowed_after;
}


// 3: Only the Owner can set the required confirmations.
rule only_owner_can_change_required_confirmations(method f) filtered { f-> !f.isView }
{
  env e;
  calldataarg args;
  uint256 chainId;

  ICrossChainReceiver.ReceiverConfiguration config_before = getConfigurationByChain(chainId);
  uint8 requiredConfirmation_before = config_before.requiredConfirmation;

  f(e, args);

  ICrossChainReceiver.ReceiverConfiguration config_after = getConfigurationByChain(chainId);
  uint8 requiredConfirmation_after = config_after.requiredConfirmation;

  assert e.msg.sender != owner() => requiredConfirmation_before == requiredConfirmation_after;
}

// A witness for the previous
rule only_owner_can_change_required_confirmations_witness_consequent(method f)
filtered {f -> f.selector == sig:updateConfirmations(ICrossChainReceiver.ConfirmationInput[]).selector}
{
  env e;
  calldataarg args;
  uint256 chainId;

  ICrossChainReceiver.ReceiverConfiguration config_before = getConfigurationByChain(chainId);
  uint8 requiredConfirmation_before = config_before.requiredConfirmation;

  f(e, args);

  ICrossChainReceiver.ReceiverConfiguration config_after = getConfigurationByChain(chainId);
  uint8 requiredConfirmation_after = config_after.requiredConfirmation;

  satisfy requiredConfirmation_before != requiredConfirmation_after;
}


// Property #4: To forward a received Envelope to the final address destination, it needs to receive at least _requiredConfirmations.

// If an envelope has (requiredConfirmations - n) confirmations, 
// then n different adaptors must call receiveCrossChainMessage in order to change the enevlope's state (checked for n=2, 3).  
// TODO: low priority - check the general case (diff > 3)
// TODO: check if exactly n confirmation arrived the state must change to confirmed. 

rule receive_more_than__requiredConfirmations_diff_2
{
  env e1;
  env e2;
  require e1.block.timestamp > 0;   
  require e1.block.timestamp <= e2.block.timestamp;   
  require e2.block.timestamp < 2 ^ 120;   
   
  bytes encodedTransaction1;
  uint256 chainId;

  bytes32 transactionId = getEncodedTransactionId(encodedTransaction1);
  mathint confirmations_before = get_confirmations(transactionId);

  bytes32 envelopeId = getEnvelopeId(encodedTransaction1);

  ICrossChainReceiver.EnvelopeState envelope_state_before = getEnvelopeState(envelopeId);
  

  receiveCrossChainMessage(e1, encodedTransaction1, chainId);
  receiveCrossChainMessage(e2, encodedTransaction1, chainId);

  ICrossChainReceiver.EnvelopeState envelope_state_after = getEnvelopeState(envelopeId);
  
  mathint confirmations_after = get_confirmations(transactionId);


  ICrossChainReceiver.ReceiverConfiguration config = getConfigurationByChain(chainId);

  assert  config.requiredConfirmation - confirmations_before == 2 && envelope_state_before != envelope_state_after
      => e1.msg.sender != e2.msg.sender;
}

//TODO: Resolve timeout and enable in CI 
rule receive_more_than__requiredConfirmations_diff_3
{
  env e1;
  env e2;
  env e3;
  require e1.block.timestamp > 0;   
  require e1.block.timestamp <= e2.block.timestamp;   
  require e2.block.timestamp <= e3.block.timestamp;   
  require e3.block.timestamp < 2 ^ 120;   
   
   
  bytes encodedTransaction1;
  uint256 chainId;

  bytes32 transactionId = getEncodedTransactionId(encodedTransaction1);
  mathint confirmations_before = get_confirmations(transactionId);

  bytes32 envelopeId = getEnvelopeId(encodedTransaction1);

  ICrossChainReceiver.EnvelopeState envelope_state_before = getEnvelopeState(envelopeId);
  

  receiveCrossChainMessage(e1, encodedTransaction1, chainId);
  receiveCrossChainMessage(e2, encodedTransaction1, chainId);
  receiveCrossChainMessage(e3, encodedTransaction1, chainId);

  ICrossChainReceiver.EnvelopeState envelope_state_after = getEnvelopeState(envelopeId);
  mathint confirmations_after = get_confirmations(transactionId);
  ICrossChainReceiver.ReceiverConfiguration config = getConfigurationByChain(chainId);

  assert  config.requiredConfirmation - confirmations_before == 3 && envelope_state_before != envelope_state_after
      => e1.msg.sender != e2.msg.sender && e1.msg.sender != e3.msg.sender && e2.msg.sender != e3.msg.sender;
}

// Property #5: An Envelope should be marked as accepted only when it reaches _requiredConfirmations.
rule receive_more_than__requiredConfirmations_diff_2_only_if
{
  env e1;
  env e2;
   
  bytes encodedTransaction1;
  uint256 chainId;

  mathint validityTimestamp = getValidityTimestamp(chainId);
  bytes32 transactionId = getEncodedTransactionId(encodedTransaction1);

  mathint firstBridgedAt = getFirstBridgedAt(transactionId);

  mathint confirmations_before = get_confirmations(transactionId);

  bytes32 envelopeId = getEnvelopeId(encodedTransaction1);

  ICrossChainReceiver.EnvelopeState envelope_state_before = getEnvelopeState(envelopeId);
  bool is_e1_msg_sender_received_before = isTransactionReceivedByAdapter(transactionId, e1.msg.sender);
  bool is_e2_msg_sender_received_before = isTransactionReceivedByAdapter(transactionId, e2.msg.sender);

  receiveCrossChainMessage(e1, encodedTransaction1, chainId);
  receiveCrossChainMessage(e2, encodedTransaction1, chainId);

  ICrossChainReceiver.EnvelopeState envelope_state_after = getEnvelopeState(envelopeId);
  
  mathint confirmations_after = get_confirmations(transactionId);


  ICrossChainReceiver.ReceiverConfiguration config = getConfigurationByChain(chainId);

  assert  e1.msg.sender != e2.msg.sender 
          && config.requiredConfirmation - confirmations_before == 2 
          && envelope_state_before == ICrossChainReceiver.EnvelopeState.None
          && !is_e1_msg_sender_received_before
          && !is_e2_msg_sender_received_before
          && validityTimestamp < firstBridgedAt 
              => envelope_state_before != envelope_state_after;
}


// Property #6: An Envelope should be delivered to destination only once.
//6.1 Cannot call receiveCrossChainMessage() and then deliverEnvelope() with the same envelope
// 6.1.a using a global call counter of _BaseReceiverPortal.receiveCrossChainMessage()
rule no_deliverEnvelope_after_receiveCrossChainMessage
{
  env e1;
  env e3;
  calldataarg args;
  
  bytes encodedTransaction;
  uint256 originChainId;
  EnvelopeUtils.Envelope envelope1 = getEnvelope(encodedTransaction);
  mathint receiveCrossChainMessage_call_counter_before = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();
  receiveCrossChainMessage(e1, encodedTransaction, originChainId);
  mathint receiveCrossChainMessage_call_counter_after = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();

  deliverEnvelope@withrevert(e3, envelope1);
  bool deliverEnvelope_reverted = lastReverted;
  assert receiveCrossChainMessage_call_counter_before != receiveCrossChainMessage_call_counter_after 
        => deliverEnvelope_reverted;

}

// 6.1.b Same as (6.1.a) just using message-specific call counter of _BaseReceiverPortal.receiveCrossChainMessage()
// The counter cannot increment twice
rule cannot_call_BaseReceiverPortal_receiveCrossChainMessage_twice
{
  env e1; env e2;
  bytes encodedTransaction; uint256 chainId;
  EnvelopeUtils.Envelope envelope = getEnvelope(encodedTransaction); 
  mathint count_before = _BaseReceiverPortalDummy.get_receive_cross_chain_message_counter
          (envelope.origin, envelope.originChainId, envelope.message);

  receiveCrossChainMessage(e1, encodedTransaction, chainId);

  deliverEnvelope(e2, envelope);
  mathint count_after = _BaseReceiverPortalDummy.get_receive_cross_chain_message_counter
            (envelope.origin, envelope.originChainId, envelope.message);

  assert count_after - count_before < 2;
}



//6.2 Cannot call receiveCrossChainMessage() twice with the same envelope
// Checking that currentContract.receiveCrossChainMessage() cannot call IBaseReceiverPortal.receiveCrossChainMessage() 
// twice with the same envelope
rule cannot_call_IBaseReceiverPortal_receiveCrossChainMessage_twice
{
  env e1;
  env e2;
  bytes encodedTransaction;
  uint256 originChainId;
  
  mathint receiveCrossChainMessage_call_counter_before = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();
  receiveCrossChainMessage(e1, encodedTransaction, originChainId);
  receiveCrossChainMessage(e2, encodedTransaction, originChainId);
  mathint receiveCrossChainMessage_call_counter_after = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();

  assert receiveCrossChainMessage_call_counter_after - receiveCrossChainMessage_call_counter_before < 2;
}

// witness
rule cannot_call_IBaseReceiverPortal_receiveCrossChainMessage_twice_witness_tight_bound
{
  env e1;
  env e2;
  bytes encodedTransaction;
  uint256 originChainId;
  
  mathint receiveCrossChainMessage_call_counter_before = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();
  receiveCrossChainMessage(e1, encodedTransaction, originChainId);
  receiveCrossChainMessage(e2, encodedTransaction, originChainId);
  mathint receiveCrossChainMessage_call_counter_after = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();

  satisfy receiveCrossChainMessage_call_counter_after - receiveCrossChainMessage_call_counter_before == 1;
}


//6.3 Cannot deliver without calling IBaseReceiverPortal.receiveCrossChainMessage()
//If envelope has become delivered then IBaseReceiverPortal.receiveCrossChainMessage() was called exactly once 
rule state_transition_to_deliver_if_IBaseReceiverPortal_receiveCrossChainMessage_called
(method f) filtered { f-> !f.isView }
{

    env e;
    calldataarg args;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);

    //global counter of non-reverting calls to IBaseReceiverPortal.receiveCrossChainMessage()
    mathint receiveCrossChainMessage_call_counter_before = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();
    f(e, args);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);
    mathint receiveCrossChainMessage_call_counter_after = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();

    assert state_before != ICrossChainReceiver.EnvelopeState.Delivered && state_after == ICrossChainReceiver.EnvelopeState.Delivered =>
        receiveCrossChainMessage_call_counter_after == receiveCrossChainMessage_call_counter_before + 1;

}

//witness
rule state_transition_to_deliver_if_IBaseReceiverPortal_receiveCrossChainMessage_called_witness_antecedent(method f)
filtered {f -> f.selector == sig:receiveCrossChainMessage(bytes,uint256).selector 
  || f.selector == sig:deliverEnvelope(EnvelopeUtils.Envelope) .selector}
{

    env e;
    calldataarg args;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);
    mathint receiveCrossChainMessage_call_counter_before = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();
    f(e, args);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);
    mathint receiveCrossChainMessage_call_counter_after = _BaseReceiverPortalDummy.receiveCrossChainMessage_success_counter();

    require state_before != ICrossChainReceiver.EnvelopeState.Delivered && state_after == ICrossChainReceiver.EnvelopeState.Delivered;
    satisfy receiveCrossChainMessage_call_counter_after == receiveCrossChainMessage_call_counter_before + 1;

}

// Property #7: A delivery of an Envelope can be triggered only if it has not been delivered yet.
// Cannot call deliverEnvelope() twice with the same envelope
rule call_deliverEnvelope_once(method f) filtered { f-> !f.isView }
{
  env e1;
  env e2;
  env e3;
  calldataarg args;
  EnvelopeUtils.Envelope envelope1;
  EnvelopeUtils.Envelope envelope3;
  deliverEnvelope(e1, envelope1);
  f(e2, args);
  deliverEnvelope@withrevert(e3, envelope3);
  bool deliverEnvelope_reverted = lastReverted;
  assert compare(envelope1, envelope3) => deliverEnvelope_reverted;

}

//witness
rule call_deliverEnvelope_once_witness_antecedent(method f) filtered { f-> !f.isView }
{
  env e1;
  env e2;
  env e3;
  calldataarg args;
  EnvelopeUtils.Envelope envelope1;
  EnvelopeUtils.Envelope envelope3;
  deliverEnvelope(e1, envelope1);
  f(e2, args);
  deliverEnvelope@withrevert(e3, envelope3);
  bool deliverEnvelope_reverted = lastReverted;
  require compare(envelope1, envelope3); 
  satisfy deliverEnvelope_reverted;

}

// Property #8: A delivery can be triggered by anyone.
rule anyone_can_call_deliverEnvelope
{
  env e;
  EnvelopeUtils.Envelope envelope;
  deliverEnvelope(e, envelope);
  satisfy e.msg.sender != owner() && e.msg.sender != guardian();
}


// Property #10: When setting a new invalidation timestamp, 
//    all previous Envelopes that have less than the _requiredConfirmations (that have not been confirmed) will be invalidated: 
//    they can not be accepted reach confirmations and so, can not be delivered.

//  If a message was received but not confirmed (# of confirmation ddi not reach the required conformation)
// and later updateMessagesValidityTimestamp() invalidated its timestamp then it cannot change its state
rule invalidate_previous_unconfirmed_envelopes_after_updateMessagesValidityTimestamp
{
    env e1;
    env e2;
    env e3;
    require e1.block.timestamp > 0;
    
    calldataarg args1;
    bytes encodedTransaction;
    uint256 chainId;
    bytes32 transactionId = getEncodedTransactionId(encodedTransaction);
    requireInvariant firstBridgedAt_happened_in_the_past(e1, transactionId);
     
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState envelope_state1 = getEnvelopeState(envelopeId);
    mathint confirmations1 = get_confirmations(transactionId);

    mathint validityTimestamp_before = getValidityTimestamp(chainId);

    //currentContract.receiveCrossChainMessage may call BaseReceiverPortal.receiveCrossChainMessage()
    // can incerements the confimration counter
    // if #conformation < requiredConfoirmation the enevelope state remains None.
    receiveCrossChainMessage(e1, encodedTransaction, chainId); 
    ICrossChainReceiver.EnvelopeState envelope_state2 = getEnvelopeState(envelopeId);
    mathint confirmations2 = get_confirmations(transactionId);

    // may change tiemStamp (invalidate previous receives), may change _requiredConfirmations
    updateMessagesValidityTimestamp(e2, args1);
    
    //If invlaidation occurred then envelope state remains None
    receiveCrossChainMessage(e2, encodedTransaction, chainId);

    ICrossChainReceiver.EnvelopeState envelope_state3 = getEnvelopeState(envelopeId);
    mathint validityTimestamp_after = getValidityTimestamp(chainId);

    assert envelope_state1 == ICrossChainReceiver.EnvelopeState.None && 
    envelope_state2 == ICrossChainReceiver.EnvelopeState.None && 
    validityTimestamp_before != validityTimestamp_after &&
    confirmations1 != confirmations2 && // first call to receiveCrossChainMessage() increased the confirmation counter
    validityTimestamp_after >= to_mathint(e1.block.timestamp) // invalidation occurred 
    => envelope_state1 == envelope_state3; //state remains None
}


//witness
rule invalidate_previous_unconfirmed_envelopes_after_updateMessagesValidityTimestamp_witness_antecedent
{
    env e1;
    env e2;
    env e3;
    require e1.block.timestamp <= e2.block.timestamp;
    require e2.block.timestamp <= e3.block.timestamp;
    require e1.block.timestamp > 0;
    require e3.block.timestamp < 2^120;
    
    calldataarg args1;
    bytes encodedTransaction;
    uint256 chainId;
    bytes32 transactionId = getEncodedTransactionId(encodedTransaction);
    requireInvariant firstBridgedAt_happened_in_the_past(e1, transactionId);
     
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState envelope_state1 = getEnvelopeState(envelopeId);
    mathint confirmations1 = get_confirmations(transactionId);

    mathint validityTimestamp_before = getValidityTimestamp(chainId);

    receiveCrossChainMessage(e1, encodedTransaction, chainId);
    ICrossChainReceiver.EnvelopeState envelope_state2 = getEnvelopeState(envelopeId);
    mathint confirmations2 = get_confirmations(transactionId);

    updateMessagesValidityTimestamp(e2, args1);
    receiveCrossChainMessage(e2, encodedTransaction, chainId);

    ICrossChainReceiver.EnvelopeState envelope_state3 = getEnvelopeState(envelopeId);
    mathint validityTimestamp_after = getValidityTimestamp(chainId);

    require envelope_state1 == ICrossChainReceiver.EnvelopeState.None && 
    envelope_state2 == ICrossChainReceiver.EnvelopeState.None && 
    validityTimestamp_before != validityTimestamp_after &&
    confirmations1 != confirmations2 &&
    validityTimestamp_after >= to_mathint(e1.block.timestamp);
    satisfy envelope_state1 == envelope_state3;
}



// If requiredConfirmation iz zero then receiveCrossChainMessage cannot change the state of any envelope
rule receiveCrossChainMessage_cannot_change_state_if_requiredConfirmation_is_zero
{
  env e;
  bytes encodedTransaction;
  uint256 chainId;

  bytes32 envelopeId = getEnvelopeId(encodedTransaction);
  ICrossChainReceiver.EnvelopeState envelope_state_before = getEnvelopeState(envelopeId);
  
  uint8 requiredConfirmation = getRequiredConfirmation(chainId);
  receiveCrossChainMessage(e, encodedTransaction, chainId);
  ICrossChainReceiver.EnvelopeState envelope_state_after = getEnvelopeState(envelopeId);

  assert requiredConfirmation == 0 => envelope_state_before == envelope_state_after;
}


//
// Internal Properties
//

// Internal property #2 state machine check - an envelope can only go in a single direction: None → confirmed → Delivered

// State transition rules
//allowed transitions are none -> confirmed, none -> delivered, confirmed -> delivered
rule envelope_state(method f) filtered { f-> !f.isView }
{
    env e;
    calldataarg args;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);
    f(e, args);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);

    assert state_before == ICrossChainReceiver.EnvelopeState.Confirmed => state_after != ICrossChainReceiver.EnvelopeState.None;
    assert state_before == ICrossChainReceiver.EnvelopeState.Delivered => state_after == ICrossChainReceiver.EnvelopeState.Delivered;
    assert state_before != ICrossChainReceiver.EnvelopeState.None => state_after != ICrossChainReceiver.EnvelopeState.None;
    
    assert state_after == ICrossChainReceiver.EnvelopeState.None => state_before == ICrossChainReceiver.EnvelopeState.None;
    assert state_after == ICrossChainReceiver.EnvelopeState.Confirmed => state_before != ICrossChainReceiver.EnvelopeState.Delivered;

}

//Transition coverage: envelope state transtions from None to Delivered
rule envelope_state_witness_none_to_delivered{
    env e;
    calldataarg args;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);
    bytes encodedTransaction;
    uint256 originChainId;
    receiveCrossChainMessage(e, encodedTransaction, originChainId);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);
    require state_before == ICrossChainReceiver.EnvelopeState.None;
    satisfy state_before == ICrossChainReceiver.EnvelopeState.None => state_after == ICrossChainReceiver.EnvelopeState.Delivered;
}

//Transition coverage: confirmed -> delivered
rule envelope_state_witness_confirmed_to_delivered{
    env e;
    calldataarg args;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);
    deliverEnvelope(e, args);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);
    require state_before == ICrossChainReceiver.EnvelopeState.Confirmed;
    satisfy state_before == ICrossChainReceiver.EnvelopeState.Confirmed => state_after == ICrossChainReceiver.EnvelopeState.Delivered;
}

//Transition coverage: none -> confirmed
rule envelope_state_witness_none_to_confirmed{

    env e;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state_before = getEnvelopeState(envelopeId);
    bytes encodedTransaction;
    uint256 originChainId;
    receiveCrossChainMessage(e, encodedTransaction, originChainId);
    ICrossChainReceiver.EnvelopeState state_after = getEnvelopeState(envelopeId);

    require state_before == ICrossChainReceiver.EnvelopeState.None;
    satisfy state_before == ICrossChainReceiver.EnvelopeState.None => state_after == ICrossChainReceiver.EnvelopeState.Confirmed;
  
}

//Coverage of 2 transitions: none -> none -> delivered
rule envelope_state_witness_none_none_confirmed{
    env e1;
    env e2;
    require e1.block.timestamp <= e2.block.timestamp;
    require e2.block.timestamp < 2^120;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state1 = getEnvelopeState(envelopeId);
    bytes encodedTransaction1;
    uint256 chainId;
    receiveCrossChainMessage(e1, encodedTransaction1, chainId);
    ICrossChainReceiver.EnvelopeState state2 = getEnvelopeState(envelopeId);
    bytes encodedTransaction2;
    uint256 originChainId2;
    receiveCrossChainMessage(e2, encodedTransaction2, originChainId2);
    ICrossChainReceiver.EnvelopeState state3 = getEnvelopeState(envelopeId);
    require state1 == ICrossChainReceiver.EnvelopeState.None;
    require state2 == ICrossChainReceiver.EnvelopeState.None;
    satisfy state3 == ICrossChainReceiver.EnvelopeState.Confirmed;
}

//Coverage of 2 transitions: none -> confirmed -> confirmed
rule envelope_state_witness_none_confirmed_confirmed{
    env e1;
    env e2;
    require e1.block.timestamp <= e2.block.timestamp;
    require e2.block.timestamp < 2^120;
    calldataarg args1;
    calldataarg args2;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state1 = getEnvelopeState(envelopeId);
    bytes encodedTransaction1;
    uint256 chainId;
    receiveCrossChainMessage(e1, encodedTransaction1, chainId);
    ICrossChainReceiver.EnvelopeState state2 = getEnvelopeState(envelopeId);
    bytes encodedTransaction2;
    uint256 originChainId2;
    receiveCrossChainMessage(e2, encodedTransaction2, originChainId2);
    ICrossChainReceiver.EnvelopeState state3 = getEnvelopeState(envelopeId);
    require state1 == ICrossChainReceiver.EnvelopeState.None;
    require state2 == ICrossChainReceiver.EnvelopeState.Confirmed;
    satisfy state3 == ICrossChainReceiver.EnvelopeState.Confirmed;
}

//Coverage of 2 transitions: confirmed -> confirmed -> confirmed
rule envelope_state_witness_confirmed_confirmed_confirmed{
    env e1;
    env e2;
    require e1.block.timestamp <= e2.block.timestamp;
    require e2.block.timestamp < 2^120;
    calldataarg args1;
    calldataarg args2;
    bytes32 envelopeId;
    ICrossChainReceiver.EnvelopeState state1 = getEnvelopeState(envelopeId);
    receiveCrossChainMessage(e1, args1);
    ICrossChainReceiver.EnvelopeState state2 = getEnvelopeState(envelopeId);
    receiveCrossChainMessage(e2, args2);
    ICrossChainReceiver.EnvelopeState state3 = getEnvelopeState(envelopeId);
    require state1 == ICrossChainReceiver.EnvelopeState.Confirmed;
    require state2 == ICrossChainReceiver.EnvelopeState.Confirmed;
    satisfy state3 == ICrossChainReceiver.EnvelopeState.Confirmed;
}


// Internal property #5: internalTransaction.confirmations grows by 1 iff bridgedByAdapter[msg.sender] changes from false to true
rule confirmations_increments_if_received_from_msg_sender(method f) filtered { f-> !f.isView }
{
  env e;
  calldataarg args;
  bytes32 transactionId;
  requireInvariant zero_firstBridgedAt_iff_not_received_from_msg_sender(e, transactionId);
  
  mathint confirmations_before = get_confirmations(transactionId);
  bool is_msg_sender_received_before = isTransactionReceivedByAdapter(transactionId, e.msg.sender);
  f(e, args);
  mathint confirmations_after = get_confirmations(transactionId);
  bool is_msg_sender_received_after = isTransactionReceivedByAdapter(transactionId, e.msg.sender);

  assert  (!is_msg_sender_received_before && is_msg_sender_received_after) <=>  confirmations_after == confirmations_before + 1;
}

//witness
rule confirmations_increments_if_received_from_msg_sender_witness
{
  env e;
  require e.block.timestamp < 2^100;
  
  bytes32 transactionId;
  requireInvariant zero_firstBridgedAt_iff_not_received_from_msg_sender(e, transactionId);

  mathint confirmations_before = get_confirmations(transactionId);
  bool is_msg_sender_received_before = isTransactionReceivedByAdapter(transactionId, e.msg.sender);
  bytes encodedTransaction;
  uint256 originChainId;
  receiveCrossChainMessage(e, encodedTransaction, originChainId);
  mathint confirmations_after = get_confirmations(transactionId);
  bool is_msg_sender_received_after = isTransactionReceivedByAdapter(transactionId, e.msg.sender);

  satisfy !is_msg_sender_received_before && is_msg_sender_received_after;
}

// Internal property #7: if a bridge is already allowed then allowReceiverBridgeAdapters() should not change the state
rule allowReceiverBridgeAdapters_cannot_disallow
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  assert is_allowed_before => is_allowed_after;
}

//witness
rule allowReceiverBridgeAdapters_cannot_disallow_witness
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require is_allowed_before; 
  satisfy is_allowed_after;
}

//Property #8: if a bridge is already disallowed then disallowReceiverBridgeAdapters() should not change the state
rule disallowReceiverBridgeAdapters_cannot_allow
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  requireInvariant addressSetInvariant(chainId);
  
  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  disallowReceiverBridgeAdapters(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  assert !is_allowed_before => !is_allowed_after;
}

//witness 1
rule disallowReceiverBridgeAdapters_cannot_allow_witness_antecedent
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  requireInvariant addressSetInvariant(chainId);

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  disallowReceiverBridgeAdapters(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require !is_allowed_before;
  satisfy !is_allowed_after;
}

//witness 2
rule disallowReceiverBridgeAdapters_cannot_allow_witness_consequent
{
  env e;
  calldataarg args;
  address bridgeAdapter;
  uint256 chainId;

  requireInvariant addressSetInvariant(chainId);

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  disallowReceiverBridgeAdapters(e, args);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require is_allowed_after;
  satisfy is_allowed_before;
}

// Internal property 11: If there are allowedBridges configured, requiredConfirmation must be configured to a positive value
rule requiredConfirmation_is_positive_after_updateConfirmations(uint256 chainId)
{
      env e;
      ICrossChainReceiver.ConfirmationInput[] newConfirmations;
      updateConfirmations(e, newConfirmations);
      // assuming that newConfirmations is not empty!
      assert newConfirmations[0].chainId == chainId => getRequiredConfirmation(chainId) > 0;
}

// Internal property #13:
// While a transaction is not confirmed yet every changing-state call to receiveCrossChainMessage increments the confirmation counter by 1
rule receive_increments_confirmations
{
  env e;
  bytes encodedTransaction;
  uint256 originChainId;
  
  bytes32 transactionId = getEncodedTransactionId(encodedTransaction);
  mathint confirmations_before = get_confirmations(transactionId);
  bytes32 envelopeId = getEnvelopeId(encodedTransaction);
  ICrossChainReceiver.EnvelopeState envelope_state_before = getEnvelopeState(envelopeId);
  
  receiveCrossChainMessage(e, encodedTransaction, originChainId);

  ICrossChainReceiver.EnvelopeState envelope_state_after = getEnvelopeState(envelopeId);
  mathint confirmations_after = get_confirmations(transactionId);

  assert  envelope_state_before != envelope_state_after => confirmations_after == confirmations_before + 1;
}

// Internal property #15: helper invariant: firstBridgedAt <= block.timestamp
invariant firstBridgedAt_happened_in_the_past(env e1, bytes32 transactionId)
        to_mathint(getFirstBridgedAt(transactionId)) <= to_mathint(e1.block.timestamp)
      {
        preserved with (env e2)
        {require e1.block.timestamp == e2.block.timestamp;}
      }

// Internal property #16: helper invariant 
invariant zero_firstBridgedAt_iff_not_received_from_msg_sender(env e1, bytes32 transactionId)
        getFirstBridgedAt(transactionId) == 0 <=> !isTransactionReceivedByAdapter(transactionId, e1.msg.sender)
      {
        preserved with (env e2)
        {
          require e1.block.timestamp == e2.block.timestamp;
          require e1.msg.sender == e2.msg.sender;
          require e1.block.timestamp < 2^100;
          require e1.block.timestamp > 0;
        }
      }


// Internal property: No side effects when allowReceiverBridgeAdapters() adds a bridge adapter.
//  Adding an adapter cannot change other adapters. 
rule only_single_bridge_adapter_added
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;
  
  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  assert 
    (adapters.length == 1 && adapters[0].chainIds.length == 1
    && (adapters[0].bridgeAdapter != bridgeAdapter || adapters[0].chainIds[0] != chainId))
        => is_allowed_before == is_allowed_after;

}

rule only_single_bridge_adapter_added_witness_antecedent
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;
 
  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require 
    (adapters.length == 1
    && adapters[0].chainIds.length == 1
    && adapters[0].bridgeAdapter != bridgeAdapter);

  satisfy  is_allowed_before == is_allowed_after;

}

// witness 1
rule only_single_bridge_adapter_added_witness_consequent_1
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;
 
  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require is_allowed_before != is_allowed_after;
  satisfy 
    adapters.length != 1 || adapters[0].chainIds.length != 1
    || (adapters[0].bridgeAdapter == bridgeAdapter && adapters[0].chainIds[0] == chainId);
}

// witness 2
rule only_single_bridge_adapter_added_witness_consequent_2
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;
  
  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require is_allowed_before != is_allowed_after;
  require adapters[0].bridgeAdapter != bridgeAdapter && adapters[0].chainIds[0] != chainId;
  satisfy (adapters.length != 1 || adapters[0].chainIds.length != 1);


}

// witness 3
rule only_single_bridge_adapter_added_witness_consequent_3
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  allowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  require is_allowed_before != is_allowed_after;
  require adapters.length == 1 && adapters[0].chainIds.length == 1;
  satisfy  adapters[0].bridgeAdapter == bridgeAdapter && adapters[0].chainIds[0] == chainId;
  

}

// Internal Property: Removing an adapter cannot change other adapters. 
rule only_single_bridge_adapter_removed
{
  env e;
  address bridgeAdapter;
  uint256 chainId;
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] adapters;

  requireInvariant addressSetInvariant(chainId);

  bool is_allowed_before  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);
  disallowReceiverBridgeAdapters(e, adapters);
  bool is_allowed_after  = isReceiverBridgeAdapterAllowed(bridgeAdapter, chainId);

  assert 
    (adapters.length == 1 && adapters[0].chainIds.length == 1
    && (adapters[0].bridgeAdapter != bridgeAdapter || adapters[0].chainIds[0] != chainId))
        => is_allowed_before == is_allowed_after;

}

rule checkUpdateMessagesValidityTimestamp{
    
    env e;
    ICrossChainReceiver.ValidityTimestampInput[] newValidityTimestamp;
    
    updateMessagesValidityTimestamp(e, newValidityTimestamp);
    
    uint256 chainId;
    uint120 validityTimestamp = getValidityTimestamp(chainId);

    bool no_duplicate_chainId = newValidityTimestamp[0].chainId != newValidityTimestamp[1].chainId && newValidityTimestamp.length <= 2;

    assert newValidityTimestamp[0].chainId == chainId && no_duplicate_chainId => newValidityTimestamp[0].validityTimestamp == validityTimestamp;
    assert newValidityTimestamp[1].chainId == chainId && no_duplicate_chainId => newValidityTimestamp[1].validityTimestamp == validityTimestamp;
}


//method reachability
rule reachability {
  env e;
  calldataarg arg;
  method f;

  f(e, arg);
  satisfy true;
}

