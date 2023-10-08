pragma solidity ^0.8.8;

import {CrossChainReceiver} from '../../src/contracts/CrossChainReceiver.sol';
import {Envelope, Transaction, TransactionUtils} from '../../src/contracts/libs/EncodingUtils.sol';
import {EnumerableSet} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ICrossChainReceiverHarness} from './ICrossChainReceiverHarness.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {IBaseReceiverPortal} from '../../src/contracts/interfaces/IBaseReceiverPortal.sol';


abstract contract CrossChainReceiverHarnessAbstract is CrossChainReceiver, ICrossChainReceiverHarness {
  using EnumerableSet for EnumerableSet.AddressSet;

    bytes malicious_s;
    Transaction transaction_s;
    Envelope envelope_s;


    function getEnvelopeId(Envelope memory envelope) external returns (bytes32){
        return envelope.getId();
    }   

    function getEncodedTransactionId(bytes memory encodedTransaction) external returns (bytes32) {
        return TransactionUtils.getId(encodedTransaction);

    }


    function getEnvelopeId(bytes memory encodedTransaction) external returns (bytes32) {
        Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
        bytes32 toReturn = transaction.getEnvelopeId();
        return toReturn; 
    }

        function getEnvelope(bytes memory encodedTransaction) external returns (Envelope memory) {
        Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
        Envelope memory toReturn = transaction.getEnvelope();
      //  require(keccak256(abi.encode(toReturn)) == keccak256(transaction.encodedEnvelope)); //TODO: reove once CERT-3193 is resolved
        return toReturn;
    }

        function getEnvelope_with_require(bytes memory encodedTransaction) external returns (Envelope memory) {
        Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
        Envelope memory toReturn = transaction.getEnvelope();
        require(keccak256(abi.encode(toReturn)) == keccak256(transaction.encodedEnvelope)); //TODO: reove once CERT-3193 is resolved
        return toReturn;
    }

    function getConfirmations(bytes32 transactionId) external view returns (uint8) {
            return _transactionsState[transactionId].confirmations;
    }
    function getFirstBridgedAt(bytes32 transactionId) external view returns (uint120) {
            return _transactionsState[transactionId].firstBridgedAt;
    }
    function getValidityTimestamp(uint256 chainId) external view returns (uint120) {
    return _configurationsByChain[chainId].configuration.validityTimestamp;
  }
    
    
    
    function compare(bytes memory b1, bytes memory b2) external pure returns (bool) {
        return keccak256(abi.encodePacked(b1)) == keccak256(abi.encodePacked(b2));
    }

    function compare(bytes32 b1, bytes32 b2) external pure returns (bool) {
        return keccak256(abi.encodePacked(b1)) == keccak256(abi.encodePacked(b2));
    //    return (b1 ==  b2);
    }

    function compare(Envelope memory envelope1, Envelope memory envelope2) external pure returns (bool) {
        return 
                envelope1.nonce == envelope2.nonce 
                && envelope1.origin == envelope2.origin        
                && envelope1.destination == envelope2.destination        
                && envelope1.originChainId == envelope2.originChainId        
                && envelope1.destinationChainId == envelope2.destinationChainId
                && keccak256(abi.encodePacked(envelope1.message)) == keccak256(abi.encodePacked(envelope2.message));
    }



      function getAllowedBridgeAdaptersLength(uint256 chainId) external view returns (uint256){
           return _configurationsByChain[chainId].allowedBridgeAdapters.length();
      }

//    function receiveCrossChainMessage_reverts() external pure returns (bool) {return false;}

//todo: remove once CERT-3411 is resolved
function compareGetIds() external returns (bool) {
    bytes memory malicious = new bytes(256);
    Transaction memory transaction = Transaction(0, malicious);
    Envelope memory envelope = transaction.getEnvelope();

    //require(keccak256(abi.encode(envelope)) == keccak256(transaction.encodedEnvelope));
    return transaction.getEnvelopeId() == envelope.getId();
}


//todo: investigate why this method is not reachable
// function compareGetIds_storage_variables() external returns (bool) {
//     bytes memory malicious = new bytes(256);
//     malicious_s = malicious;
//  //   transaction_s = Transaction(0, malicious_s);
//  //   envelope_s = transaction_s.getEnvelope();

//  //   require(keccak256(abi.encode(envelope_s)) == keccak256(transaction_s.encodedEnvelope));
//     return true; // transaction_s.getEnvelopeId() == envelope_s.getId();
// }


//todo: remove once CERT-3193 is resolved
function short_receiveCrossChainMessage(
    bytes memory encodedTransaction,
    uint256 originChainId
  ) external onlyApprovedBridges(originChainId) {
    Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
    Envelope memory envelope = transaction.getEnvelope();
    require(
      envelope.originChainId == originChainId && envelope.destinationChainId == block.chainid,
      Errors.CHAIN_ID_MISMATCH
    );
    bytes32 envelopeId = transaction.getEnvelopeId();
    // if envelope was confirmed before, just return
    if (_envelopesState[envelopeId] != EnvelopeState.None) return;

    bytes32 transactionId = TransactionUtils.getId(encodedTransaction);
    TransactionState storage internalTransaction = _transactionsState[transactionId];
    ReceiverConfiguration memory configuration = _configurationsByChain[originChainId]
      .configuration;

    // If bridged at is > invalidation, it means that the first time transaction was received after last invalidation and
    // can be processed.
    // 0 here means that it’s received for a first time, so invalidation does not matter for this message.
    // Also checks that bridge adapter didn’t bridge this transaction already.
    // Dont let messages pass if required confirmations are 0. Meaning that they have not been configured
    uint120 transactionFirstBridgedAt = internalTransaction.firstBridgedAt;
    if (
      transactionFirstBridgedAt == 0 ||
      (!internalTransaction.bridgedByAdapter[msg.sender] &&
        transactionFirstBridgedAt > configuration.validityTimestamp)
    ) {
      if (transactionFirstBridgedAt == 0) {
        internalTransaction.firstBridgedAt = uint120(block.timestamp);
      }

      uint8 newConfirmations = ++internalTransaction.confirmations;
      internalTransaction.bridgedByAdapter[msg.sender] = true;

      emit TransactionReceived(
        transactionId,
        envelopeId,
        originChainId,
        transaction,
        msg.sender,
        newConfirmations
      );

      // checks that the message was not delivered before, so it will not try to deliver again when message arrives
      // from additional bridges after reaching required number of confirmations
      // >= is used for the case when confirmations gets lowered before message reached the old _requiredConfirmations
      // but on receiving new messages it surpasses the current _requiredConfirmations. So it doesn't get stuck (if using ==)
      if (
        configuration.requiredConfirmation > 0 &&
        newConfirmations >= configuration.requiredConfirmation
      ) {
        _envelopesState[envelopeId] = EnvelopeState.Delivered;
        try
          IBaseReceiverPortal(envelope.destination).receiveCrossChainMessage(
            envelope.origin,
            envelope.originChainId,
            envelope.message
          )
        {
          emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
        } catch (bytes memory) {
          _envelopesState[envelopeId] = EnvelopeState.Confirmed;
          emit EnvelopeDeliveryAttempted(envelopeId, envelope, false);
        }
      }
    }
  }

}