// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseCCReceiver.t.sol';
import {Errors} from '../src/contracts/libs/Errors.sol';
import {FailingReceiver} from './mocks/FailingReceiver.sol';

contract ReceiverTest is BaseCCReceiverTest {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;

  function testReceiveCrossChainMessage(
    uint256 originChainId,
    uint8 confirmations,
    uint256 transactionNonce,
    uint256 envelopeNonce,
    address origin,
    address destination
  )
    public
    filterAddress(destination)
    setConfirmations(confirmations, originChainId)
    setBridgeAdapters(confirmations, originChainId)
  {
    vm.assume(origin != address(0));
    vm.assume(destination != address(0));

    _validateTestReceiveMessageSuccessfulAndDelivered(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: transactionNonce,
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      }),
      confirmations
    );
  }

  function testReceiveCrossChainMessageNoConfirmation(
    uint256 originChainId,
    uint256 transactionNonce,
    uint256 envelopeNonce,
    address origin,
    address destination
  )
    public
    filterAddress(destination)
    setConfirmations(5, originChainId)
    setBridgeAdapters(4, originChainId)
  {
    vm.assume(origin != address(0));
    vm.assume(destination != address(0));

    _validateTestReceiveMessageSuccessfulNoConfirmation(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: transactionNonce,
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      }),
      4
    );
  }

  function testReceiveCrossChainMessageFailDelivery(
    uint256 originChainId,
    uint8 confirmations,
    uint256 transactionNonce,
    uint256 envelopeNonce,
    address origin
  )
    public
    setConfirmations(confirmations, originChainId)
    setBridgeAdapters(confirmations, originChainId)
  {
    vm.assume(origin != address(0));

    _validateTestReceiveMessageSuccessfulAndDelivered(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: transactionNonce,
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: address(new FailingReceiver())
      }),
      confirmations
    );
  }

  function testDeliverEnvelope(
    uint256 envelopeNonce,
    uint256 originChainId,
    address origin,
    address destination
  ) public filterAddress(destination) {
    vm.assume(origin != address(0));
    vm.assume(destination != address(0));

    _validateDeliverEnvelopeSuccessful(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      })
    );
  }

  function testDeliverEnvelopeWhenNotConfirmed(
    uint256 envelopeNonce,
    uint256 originChainId,
    address origin,
    address destination
  )
    public
    filterAddress(destination)
    setEnvelopeState(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      }),
      ICrossChainReceiver.EnvelopeState.None
    )
  {
    vm.assume(origin != address(0));
    vm.assume(destination != address(0));

    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      })
    );

    vm.expectRevert(bytes(Errors.ENVELOPE_NOT_CONFIRMED_OR_DELIVERED));
    this.deliverEnvelope(extendedTx.envelope);
  }

  function testDeliverEnvelopeWhenAlreadyDelivered(
    uint256 envelopeNonce,
    uint256 originChainId,
    address origin,
    address destination
  )
    public
    filterAddress(destination)
    setEnvelopeState(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      }),
      ICrossChainReceiver.EnvelopeState.Delivered
    )
  {
    vm.assume(origin != address(0));
    vm.assume(destination != address(0));

    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: destination
      })
    );

    vm.expectRevert(bytes(Errors.ENVELOPE_NOT_CONFIRMED_OR_DELIVERED));
    this.deliverEnvelope(extendedTx.envelope);
  }

  function testDeliverEnvelopeWhenDeliveryFails(
    uint256 envelopeNonce,
    uint256 originChainId,
    address origin
  ) public {
    vm.assume(origin != address(0));

    _validateDeliveryFailed(
      TestParams({
        originChainId: originChainId,
        destinationChainId: block.chainid,
        transactionNonce: 0, // not used
        envelopeNonce: envelopeNonce,
        origin: origin,
        destination: address(new FailingReceiver())
      })
    );
  }

  // ------------- test validations -----------------
  function _validateDeliveryFailed(
    TestParams memory testParams
  ) internal setEnvelopeState(testParams, ICrossChainReceiver.EnvelopeState.Confirmed) {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);
    vm.expectRevert(bytes('error message'));
    this.deliverEnvelope(extendedTx.envelope);
  }

  function _validateDeliverEnvelopeSuccessful(
    TestParams memory testParams
  )
    internal
    setEnvelopeState(testParams, ICrossChainReceiver.EnvelopeState.Confirmed)
    validateEnvelope(ICrossChainReceiver.EnvelopeState.Delivered, testParams)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);

    _mockDeliveryAsSuccess(
      extendedTx.envelope.destination,
      extendedTx.envelope.origin,
      extendedTx.envelope.originChainId
    );

    vm.expectEmit(true, true, true, true);
    emit EnvelopeDeliveryAttempted(extendedTx.envelopeId, extendedTx.envelope, true);
    this.deliverEnvelope(extendedTx.envelope);
  }

  function _validateTestReceiveMessageFailDelivery(
    TestParams memory testParams,
    uint256 confirmations
  )
    internal
    validateEnvelope(ICrossChainReceiver.EnvelopeState.Confirmed, testParams)
    validateTransactionState(testParams, confirmations)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);

    address[] memory bridgeAdapters = _configurationsByChain[extendedTx.envelope.originChainId]
      .allowedBridgeAdapters
      .values();
    for (uint256 i = 0; i < bridgeAdapters.length; i++) {
      hoax(bridgeAdapters[i]);
      vm.expectEmit(true, true, true, true);
      emit TransactionReceived(
        extendedTx.transactionId,
        extendedTx.envelopeId,
        extendedTx.envelope.originChainId,
        extendedTx.transaction,
        bridgeAdapters[i],
        uint8(i + 1)
      );
      if (i + 1 == confirmations) {
        vm.expectEmit(true, true, true, true);
        emit EnvelopeDeliveryAttempted(extendedTx.envelopeId, extendedTx.envelope, false);
      }
      this.receiveCrossChainMessage(
        extendedTx.transactionEncoded,
        extendedTx.envelope.originChainId
      );
    }
  }

  function _validateTestReceiveMessageSuccessfulNoConfirmation(
    TestParams memory testParams,
    uint256 confirmations
  )
    internal
    validateEnvelope(ICrossChainReceiver.EnvelopeState.None, testParams)
    validateTransactionState(testParams, confirmations)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);

    _mockDeliveryAsSuccess(
      extendedTx.envelope.destination,
      extendedTx.envelope.origin,
      extendedTx.envelope.originChainId
    );

    address[] memory bridgeAdapters = _configurationsByChain[extendedTx.envelope.originChainId]
      .allowedBridgeAdapters
      .values();
    for (uint256 i = 0; i < bridgeAdapters.length; i++) {
      hoax(bridgeAdapters[i]);
      vm.expectEmit(true, true, true, true);
      emit TransactionReceived(
        extendedTx.transactionId,
        extendedTx.envelopeId,
        extendedTx.envelope.originChainId,
        extendedTx.transaction,
        bridgeAdapters[i],
        uint8(i + 1)
      );

      this.receiveCrossChainMessage(
        extendedTx.transactionEncoded,
        extendedTx.envelope.originChainId
      );
    }
  }

  function _validateTestReceiveMessageSuccessfulAndDelivered(
    TestParams memory testParams,
    uint256 confirmations
  )
    internal
    validateEnvelope(ICrossChainReceiver.EnvelopeState.Delivered, testParams)
    validateTransactionState(testParams, confirmations)
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);

    _mockDeliveryAsSuccess(
      extendedTx.envelope.destination,
      extendedTx.envelope.origin,
      extendedTx.envelope.originChainId
    );

    address[] memory bridgeAdapters = _configurationsByChain[extendedTx.envelope.originChainId]
      .allowedBridgeAdapters
      .values();
    for (uint256 i = 0; i < bridgeAdapters.length; i++) {
      hoax(bridgeAdapters[i]);
      vm.expectEmit(true, true, true, true);
      emit TransactionReceived(
        extendedTx.transactionId,
        extendedTx.envelopeId,
        extendedTx.envelope.originChainId,
        extendedTx.transaction,
        bridgeAdapters[i],
        uint8(i + 1)
      );
      if (i + 1 == confirmations) {
        vm.expectEmit(true, true, true, true);
        emit EnvelopeDeliveryAttempted(extendedTx.envelopeId, extendedTx.envelope, true);
      }
      this.receiveCrossChainMessage(
        extendedTx.transactionEncoded,
        extendedTx.envelope.originChainId
      );
    }
  }
}
