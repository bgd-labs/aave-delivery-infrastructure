// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../src/contracts/CrossChainForwarder.sol';
import './BaseTest.sol';
import {FailingAdapter} from './mocks/FailingAdapter.sol';

contract BaseCCForwarderTest is BaseTest, CrossChainForwarder {
  address internal constant CROSS_CHAIN_CONTROLLER = address(123029525691); // can be hardcoded as its not consequential to testing
  uint256 internal constant GAS_LIMIT = 500_000;

  enum AdapterSuccessType {
    ALL_FAILING,
    ALL_SUCCESS,
    SOME_SUCCESS
  }

  struct UsedAdapter {
    ICrossChainForwarder.ChainIdBridgeConfig bridgeAdapterConfig;
    bool success;
    bytes returnData;
  }

  mapping(uint256 => UsedAdapter[]) internal _currentlyUsedAdaptersByChain;
  mapping(address => bool) internal _adapterSuccess;

  function setUp() public {}

  constructor()
    CrossChainForwarder(
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new address[](0)
    )
  {}

  // ------------------- Setter modifiers --------------------------
  modifier executeAsOwner(address owner) {
    vm.assume(owner != address(0));
    _transferOwnership(owner);
    vm.startPrank(owner);
    _;
    vm.stopPrank();
  }

  modifier executeAsGuardian(address guardian) {
    vm.assume(guardian != address(0));
    _updateGuardian(guardian);
    vm.startPrank(guardian);
    _;
    vm.stopPrank();
  }

  modifier approveSender(address sender) {
    vm.assume(sender != address(0));

    _approveSender(sender);
    _;
  }

  function _deployFailingAdapter() internal returns (address) {
    FailingAdapter.TrustedRemotesConfig[]
      memory trustedRemotes = new FailingAdapter.TrustedRemotesConfig[](1);
    trustedRemotes[0].originForwarder = address(1);
    trustedRemotes[0].originChainId = 1;
    return address(new FailingAdapter(trustedRemotes));
  }

  modifier enableBridgeAdaptersForPath(
    uint256 destinationChainId,
    uint256 numberOfAdapters,
    AdapterSuccessType adaptersType
  ) {
    // get adapters for destination chain id
    delete _currentlyUsedAdaptersByChain[destinationChainId];

    for (uint256 i = 1; i < numberOfAdapters + 1; i++) {
      address currentChainBridgeAdapter;
      if (
        adaptersType == AdapterSuccessType.ALL_SUCCESS ||
        (adaptersType == AdapterSuccessType.SOME_SUCCESS && i % 2 == 0)
      ) {
        currentChainBridgeAdapter = address(uint160(uint(keccak256(abi.encodePacked(i)))));
        _adapterSuccess[currentChainBridgeAdapter] = true;
      } else {
        currentChainBridgeAdapter = _deployFailingAdapter();
        _adapterSuccess[currentChainBridgeAdapter] = false;
      }
      address destinationBridgeAdapter = address(
        uint160(uint(keccak256(abi.encodePacked(i + numberOfAdapters + 1))))
      );

      bytes memory returnData = _adapterSuccess[currentChainBridgeAdapter]
        ? bytes('')
        : abi.encodeWithSignature('Error(string)', 'error message');

      UsedAdapter memory usedBridgeAdapter = UsedAdapter({
        bridgeAdapterConfig: ICrossChainForwarder.ChainIdBridgeConfig({
          destinationBridgeAdapter: destinationBridgeAdapter,
          currentChainBridgeAdapter: currentChainBridgeAdapter
        }),
        success: _adapterSuccess[currentChainBridgeAdapter],
        returnData: returnData
      });
      _currentlyUsedAdaptersByChain[destinationChainId].push(usedBridgeAdapter);

      _enableBridgeAdapterForPath(
        destinationChainId,
        currentChainBridgeAdapter,
        destinationBridgeAdapter
      );
    }

    _;
  }

  modifier setRequiredConfirmations(uint256 destinationChainId, uint256 requiredConfirmations) {
    RequiredConfirmationsByReceiverChain[]
      memory requiredConfirmationsByReceiverChain = new RequiredConfirmationsByReceiverChain[](1);
    requiredConfirmationsByReceiverChain[0].requiredConfirmations = requiredConfirmations;
    requiredConfirmationsByReceiverChain[0].chainId = destinationChainId;

    _updateRequiredConfirmationsForReceiverChain(requiredConfirmationsByReceiverChain);
    _;
  }

  // ------------------- Validators modifiers --------------------------
  modifier validateEnvelopeNonceIncrement() {
    uint256 beforeNonce = _currentEnvelopeNonce;
    _;
    assertEq(beforeNonce + 1, _currentEnvelopeNonce);
  }

  modifier validateTransactionNonceIncrement() {
    uint256 beforeNonce = _currentTransactionNonce;
    _;
    assertEq(beforeNonce + 1, _currentTransactionNonce);
  }

  modifier validateEnvelopeNonceStayedSame() {
    uint256 beforeNonce = _currentEnvelopeNonce;
    _;
    assertEq(beforeNonce, _currentEnvelopeNonce);
  }

  modifier validateTransactionNonceStayedSame() {
    uint256 beforeNonce = _currentTransactionNonce;
    _;
    assertEq(beforeNonce, _currentTransactionNonce);
  }

  modifier validateEnvelopRegistry(ExtendedTransaction memory extendedTx) {
    assertEq(_registeredEnvelopes[extendedTx.envelopeId], false);
    _;
    assertEq(_registeredEnvelopes[extendedTx.envelopeId], true);
  }

  modifier validateTransactionRegistry(ExtendedTransaction memory extendedTx) {
    bool beforeRegistry = _forwardedTransactions[extendedTx.transactionId];
    _;
    assertEq(beforeRegistry, false);
    assertEq(_forwardedTransactions[extendedTx.transactionId], true);
  }

  modifier validateRetryTransactionRegistry(ExtendedTransaction memory extendedTx) {
    _;
    assertEq(_forwardedTransactions[extendedTx.transactionId], true);
  }

  modifier validateTransactionNotRegistered(ExtendedTransaction memory extendedTx) {
    assertEq(_forwardedTransactions[extendedTx.transactionId], false);
    _;
    assertEq(_forwardedTransactions[extendedTx.transactionId], false);
  }

  modifier validateRequiredConfirmationsUsed(
    ExtendedTransaction memory extendedTx,
    uint256 requiredConfirmations
  ) {
    _;
    uint256 destinationChainId = extendedTx.envelope.destinationChainId;
    UsedAdapter[] memory usedAdapters = _currentlyUsedAdaptersByChain[destinationChainId];
    uint256 successfulAdapters;
    uint256 length = requiredConfirmations >= usedAdapters.length
      ? usedAdapters.length
      : requiredConfirmations;
    for (uint256 i = 0; i < length; i++) {
      if (usedAdapters[i].success) {
        successfulAdapters++;
      }
    }

    uint256 numberOfAdapters = this.getForwarderBridgeAdaptersByChain(destinationChainId).length;

    if (requiredConfirmations == 0 || requiredConfirmations >= numberOfAdapters) {
      assertEq(successfulAdapters, numberOfAdapters);
    } else {
      assertEq(successfulAdapters, requiredConfirmations);
    }
  }

  // ----- internal tests helpers ---------------

  function _registerEnvelope(ExtendedTransaction memory extendedTx) internal {
    _registeredEnvelopes[extendedTx.envelopeId] = true;
  }

  function _registerTransaction(ExtendedTransaction memory extendedTx) internal {
    _forwardedTransactions[extendedTx.transactionId] = true;
  }

  function _testForwardMessage(
    ExtendedTransaction memory extendedTx,
    uint256 requiredConfirmations
  ) internal {
    _mockAdaptersForwardMessage(extendedTx.envelope.destinationChainId);
    vm.expectEmit(true, true, true, true);
    emit EnvelopeRegistered(extendedTx.envelopeId, extendedTx.envelope);
    UsedAdapter[] memory usedAdapters = _currentlyUsedAdaptersByChain[
      extendedTx.envelope.destinationChainId
    ];

    ChainIdBridgeConfig[] memory shuffledAdapters = _getShuffledBridgeAdaptersByChain(
      extendedTx.envelope.destinationChainId
    );
    for (uint256 i = 0; i < shuffledAdapters.length; i++) {
      for (uint256 j = 0; j < usedAdapters.length; j++) {
        if (
          usedAdapters[j].bridgeAdapterConfig.currentChainBridgeAdapter ==
          shuffledAdapters[i].currentChainBridgeAdapter &&
          usedAdapters[j].bridgeAdapterConfig.destinationBridgeAdapter ==
          shuffledAdapters[i].destinationBridgeAdapter
        ) {
          vm.expectEmit(true, true, true, true);
          emit TransactionForwardingAttempted(
            extendedTx.transactionId,
            extendedTx.envelopeId,
            extendedTx.transactionEncoded,
            extendedTx.envelope.destinationChainId,
            usedAdapters[j].bridgeAdapterConfig.currentChainBridgeAdapter,
            usedAdapters[j].bridgeAdapterConfig.destinationBridgeAdapter,
            usedAdapters[j].success,
            usedAdapters[j].returnData
          );
        }
      }
    }
    (bytes32 returnedEnvelopeId, bytes32 returnedTransactionId) = this.forwardMessage(
      extendedTx.envelope.destinationChainId,
      extendedTx.envelope.destination,
      GAS_LIMIT,
      MESSAGE
    );

    assertEq(extendedTx.envelopeId, returnedEnvelopeId);
    assertEq(extendedTx.transactionId, returnedTransactionId);
  }

  // ----------- Helper methods -------------------

  function _mockAdaptersForwardMessage(uint256 destinationChainId) internal {
    ICrossChainForwarder.ChainIdBridgeConfig[] memory bridgeAdapters = this
      .getForwarderBridgeAdaptersByChain(destinationChainId);

    for (uint256 i = 0; i < bridgeAdapters.length; i++) {
      if (_adapterSuccess[bridgeAdapters[i].currentChainBridgeAdapter]) {
        vm.mockCall(
          bridgeAdapters[i].currentChainBridgeAdapter,
          abi.encodeWithSelector(IBaseAdapter.forwardMessage.selector),
          abi.encode()
        );
      }
    }
  }

  function _enableBridgeAdapterForPath(
    uint256 destinationChainId,
    address currentChainBridgeAdapter,
    address destinationBridgeAdapter
  ) internal {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory bridgeAdaptersInfo = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](1);

    bridgeAdaptersInfo[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: currentChainBridgeAdapter,
      destinationBridgeAdapter: destinationBridgeAdapter,
      destinationChainId: destinationChainId
    });

    vm.mockCall(
      address(currentChainBridgeAdapter),
      abi.encodeWithSelector(IBaseAdapter.setupPayments.selector),
      abi.encode()
    );
    _enableBridgeAdapters(bridgeAdaptersInfo);
  }

  function _approveSender(address sender) internal {
    address[] memory sendersToApprove = new address[](1);
    sendersToApprove[0] = sender;
    _updateSenders(sendersToApprove, true);
  }
}
