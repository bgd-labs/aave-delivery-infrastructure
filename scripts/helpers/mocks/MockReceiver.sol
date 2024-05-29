// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Transaction, Envelope, TransactionUtils} from '../../../src/contracts/libs/EncodingUtils.sol';

interface IMockReceiver {
  event Chains(
    uint256 indexed envelopeOriginChainId,
    uint256 indexed envelopeDestChainId,
    uint256 indexed blockChainId,
    uint256 argOriginChainId
  );
  event ChainCheck(bool indexed passed);

  function receiveCrossChainMessage(
    bytes memory encodedTransaction,
    uint256 originChainId
  ) external returns (uint256, uint256, uint256, uint256, bool);
}

contract MockReceiver is IMockReceiver {
  function receiveCrossChainMessage(
    bytes memory encodedTransaction,
    uint256 originChainId
  ) external returns (uint256, uint256, uint256, uint256, bool) {
    Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
    Envelope memory envelope = transaction.getEnvelope();
    emit Chains(envelope.originChainId, envelope.destinationChainId, block.chainid, originChainId);

    bool passed = envelope.originChainId == originChainId &&
      envelope.destinationChainId == block.chainid;
    emit ChainCheck(passed);

    return (
      envelope.originChainId,
      envelope.destinationChainId,
      block.chainid,
      originChainId,
      passed
    );
  }
}
