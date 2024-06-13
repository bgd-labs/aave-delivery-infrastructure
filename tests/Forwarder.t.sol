// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseCCForwarder.t.sol';
import {Errors} from '../src/contracts/libs/Errors.sol';

contract ForwarderTest is BaseCCForwarderTest {
  function testForwardMessageAllAdaptersWorking(
    address destination,
    address origin,
    uint256 destinationChainId
  )
    public
    executeAs(origin)
    approveSender(origin)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.ALL_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: _currentEnvelopeNonce,
        transactionNonce: _currentTransactionNonce
      })
    );
    _validateForwardMessageWhenAtLeastOneAdapterWorking(extendedTx);
  }

  function testForwardMessageWhenAdaptersNotWorking(
    address destination,
    address origin,
    uint256 destinationChainId
  )
    public
    executeAs(origin)
    approveSender(origin)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.ALL_FAILING)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: _currentEnvelopeNonce,
        transactionNonce: _currentTransactionNonce
      })
    );
    _validateForwardMessageWhenNoAdapterWorking(extendedTx);
  }

  function testForwardMessageWhenSomeAdaptersNotWorking(
    address destination,
    address origin,
    uint256 destinationChainId
  )
    public
    executeAs(origin)
    approveSender(origin)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.SOME_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: _currentEnvelopeNonce,
        transactionNonce: _currentTransactionNonce
      })
    );
    _validateForwardMessageWhenAtLeastOneAdapterWorking(extendedTx);
  }

  function testRetryEnvelope(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.ALL_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: _currentTransactionNonce
      })
    );
    _registerEnvelope(extendedTx);
    _validateRetryEnvelopeSuccessful(extendedTx);
  }

  function testRetryEnvelopeWhenNoAdapters(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  ) public executeAsOwner(owner) {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerEnvelope(extendedTx);
    vm.expectRevert(bytes(Errors.NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN));
    this.retryEnvelope(extendedTx.envelope, GAS_LIMIT);
  }

  function testRetryNonRegisteredEnvelope(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.ALL_SUCCESS)
  {
    vm.expectRevert(bytes(Errors.ENVELOPE_NOT_PREVIOUSLY_REGISTERED));
    this.retryEnvelope(
      Envelope({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        nonce: envelopeNonce,
        message: MESSAGE
      }),
      GAS_LIMIT
    );
  }

  function testRetryTransaction(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.SOME_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerTransaction(extendedTx);
    _validateRetryTransactionSuccessful(extendedTx);
  }

  function testRetryTransactionWhenAllAdaptersFail(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.ALL_FAILING)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerTransaction(extendedTx);
    _validateRetryTransactionWhenAllAdaptersFail(extendedTx);
  }

  function testRetryTransactionWhenNotRegistered(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.SOME_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );

    vm.expectRevert(bytes(Errors.TRANSACTION_NOT_PREVIOUSLY_FORWARDED));
    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, new address[](0));
  }

  function testRetryTransactionWhenAdaptersNotRegistered(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.SOME_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerTransaction(extendedTx);
    _validateRetryTransactionWhenAdaptersNotRegistered(extendedTx);
  }

  function testRetryTransactionWhenNoAdapters(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  ) public executeAsOwner(owner) {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerTransaction(extendedTx);
    vm.expectRevert(bytes(Errors.NO_BRIDGE_ADAPTERS_FOR_SPECIFIED_CHAIN));
    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, new address[](0));
  }

  function testRetryTransactionWhenAdaptersNotUnique(
    address destination,
    address origin,
    uint256 destinationChainId,
    address owner,
    uint256 envelopeNonce,
    uint256 transactionNonce
  )
    public
    executeAsOwner(owner)
    enableBridgeAdaptersForPath(destinationChainId, 5, AdapterSuccessType.SOME_SUCCESS)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: origin,
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envelopeNonce,
        transactionNonce: transactionNonce
      })
    );
    _registerTransaction(extendedTx);
    _validateRetryTransactionWhenAdaptersNotUnique(extendedTx);
  }

  // ----------- validations ----------------------
  function _validateRetryTransactionWhenAllAdaptersFail(
    ExtendedTransaction memory extendedTx
  ) internal {
    address[] memory bridgeAdaptersToRetry = new address[](1);
    bridgeAdaptersToRetry[0] = _currentlyUsedAdaptersByChain[
      extendedTx.envelope.destinationChainId
    ][0].bridgeAdapterConfig.currentChainBridgeAdapter;
    vm.expectRevert(bytes(Errors.TRANSACTION_RETRY_FAILED));

    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, bridgeAdaptersToRetry);
  }

  function _validateRetryTransactionWhenAdaptersNotRegistered(
    ExtendedTransaction memory extendedTx
  ) internal {
    address[] memory bridgeAdaptersToRetry = new address[](1);
    bridgeAdaptersToRetry[0] = address(202341);
    vm.expectRevert(bytes(Errors.INVALID_BRIDGE_ADAPTER));
    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, bridgeAdaptersToRetry);
  }

  function _validateRetryTransactionWhenAdaptersNotUnique(
    ExtendedTransaction memory extendedTx
  ) internal {
    address[] memory bridgeAdaptersToRetry = new address[](2);
    bridgeAdaptersToRetry[0] = address(1);
    bridgeAdaptersToRetry[1] = address(1);
    vm.expectRevert(bytes(Errors.BRIDGE_ADAPTERS_SHOULD_BE_UNIQUE));
    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, bridgeAdaptersToRetry);
  }

  function _validateRetryTransactionSuccessful(
    ExtendedTransaction memory extendedTx
  )
    internal
    validateEnvelopeNonceStayedSame
    validateTransactionNonceStayedSame
    validateRetryTransactionRegistry(extendedTx)
  {
    uint256 failedAdaptersCounter;
    for (
      uint256 j = 0;
      j < _currentlyUsedAdaptersByChain[extendedTx.envelope.destinationChainId].length;
      j++
    ) {
      if (
        _currentlyUsedAdaptersByChain[extendedTx.envelope.destinationChainId][j].success == true
      ) {
        failedAdaptersCounter++;
      }
    }

    address[] memory bridgeAdaptersToRetry = new address[](failedAdaptersCounter);
    ICrossChainForwarder.ChainIdBridgeConfig[]
      memory bridgeAdaptersToRetryConfig = new ICrossChainForwarder.ChainIdBridgeConfig[](
        failedAdaptersCounter
      );

    uint256 index = 0;
    for (
      uint256 k = 0;
      k < _currentlyUsedAdaptersByChain[extendedTx.envelope.destinationChainId].length;
      k++
    ) {
      if (
        _currentlyUsedAdaptersByChain[extendedTx.envelope.destinationChainId][k].success
      ) {
        bridgeAdaptersToRetry[index] = _currentlyUsedAdaptersByChain[
          extendedTx.envelope.destinationChainId
        ][k].bridgeAdapterConfig.currentChainBridgeAdapter;
        bridgeAdaptersToRetryConfig[index] = _currentlyUsedAdaptersByChain[
          extendedTx.envelope.destinationChainId
        ][k].bridgeAdapterConfig;
        index++;
      }
    }

    _mockAdaptersForwardMessage(extendedTx.envelope.destinationChainId);

    for (uint256 i = 0; i < bridgeAdaptersToRetryConfig.length; i++) {
      vm.expectEmit(true, true, true, true);
      emit TransactionForwardingAttempted(
        extendedTx.transactionId,
        extendedTx.envelopeId,
        extendedTx.transactionEncoded,
        extendedTx.envelope.destinationChainId,
        bridgeAdaptersToRetryConfig[i].currentChainBridgeAdapter,
        bridgeAdaptersToRetryConfig[i].destinationBridgeAdapter,
        true,
        hex'00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
      );
    }
    this.retryTransaction(extendedTx.transactionEncoded, GAS_LIMIT, bridgeAdaptersToRetry);
  }

  function _validateRetryEnvelopeSuccessful(
    ExtendedTransaction memory extendedTx
  )
    internal
    validateEnvelopeNonceStayedSame
    validateTransactionNonceIncrement
    validateTransactionRegistry(extendedTx)
  {
    UsedAdapter[] memory usedAdapters = _currentlyUsedAdaptersByChain[
      extendedTx.envelope.destinationChainId
    ];
    for (uint256 i = 0; i < usedAdapters.length; i++) {
      vm.expectEmit(true, true, true, true);
      emit TransactionForwardingAttempted(
        extendedTx.transactionId,
        extendedTx.envelopeId,
        extendedTx.transactionEncoded,
        extendedTx.envelope.destinationChainId,
        usedAdapters[i].bridgeAdapterConfig.currentChainBridgeAdapter,
        usedAdapters[i].bridgeAdapterConfig.destinationBridgeAdapter,
        usedAdapters[i].success,
        hex'00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
      );
    }
    bytes32 transactionId = this.retryEnvelope(extendedTx.envelope, GAS_LIMIT);
    assertEq(extendedTx.transactionId, transactionId);
  }

  function _validateForwardMessageWhenAtLeastOneAdapterWorking(
    ExtendedTransaction memory extendedTx
  )
    internal
    validateEnvelopeNonceIncrement
    validateTransactionNonceIncrement
    validateEnvelopRegistry(extendedTx)
    validateTransactionRegistry(extendedTx)
  {
    _testForwardMessage(extendedTx);
  }

  function _validateForwardMessageWhenNoAdapterWorking(
    ExtendedTransaction memory extendedTx
  )
    internal
    validateEnvelopeNonceIncrement
    validateTransactionNonceIncrement
    validateEnvelopRegistry(extendedTx)
    validateTransactionRegistry(extendedTx)
  {
    _testForwardMessage(extendedTx);
  }
}
