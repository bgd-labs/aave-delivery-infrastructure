// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../src/contracts/CrossChainReceiver.sol';
import './BaseTest.sol';
import {FailingAdapter} from './mocks/FailingAdapter.sol';

contract BaseCCReceiverTest is BaseTest, CrossChainReceiver {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;

  constructor()
    CrossChainReceiver(new ConfirmationInput[](0), new ReceiverBridgeAdapterConfigInput[](0))
  {}

  function setUp() public {}

  modifier setConfirmations(uint8 confirmations, uint256 chainId) {
    vm.assume(confirmations > 0);
    _configurationsByChain[chainId].configuration.requiredConfirmation = confirmations;
    _;
  }

  modifier setBridgeAdapters(uint8 confirmations, uint256 chainId) {
    vm.assume(confirmations > 0);
    ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = _getAdaptersConfigToSatisfyConfirmations(
        uint256(confirmations),
        chainId
      );

    _updateReceiverBridgeAdapters(bridgeAdapters, true);

    _;
  }

  modifier setEnvelopeState(TestParams memory testParams, EnvelopeState envelopeState) {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);
    _envelopesState[extendedTx.envelopeId] = envelopeState;
    _;
  }

  // ----------- validations -----------------
  modifier validateTransactionState(TestParams memory testParams, uint256 confirmations) {
    _;
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);

    TransactionStateWithoutAdapters memory transactionState = this.getTransactionState(
      extendedTx.transactionId
    );

    assertEq(transactionState.confirmations, confirmations);
    assertEq(uint256(transactionState.firstBridgedAt), block.timestamp);

    for (uint i = 0; i < confirmations; i++) {
      assertEq(
        this.isTransactionReceivedByAdapter(
          extendedTx.transactionId,
          _configurationsByChain[extendedTx.envelope.originChainId].allowedBridgeAdapters.values()[
            i
          ]
        ),
        true
      );
    }
  }

  modifier validateEnvelope(EnvelopeState envelopeState, TestParams memory testParams) {
    _;
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(testParams);
    assertTrue(_envelopesState[extendedTx.envelopeId] == envelopeState);
  }

  // ------------ helpers -----------------
  function _getAdaptersConfigToSatisfyConfirmations(
    uint256 confirmations,
    uint256 chainId
  ) internal pure returns (ReceiverBridgeAdapterConfigInput[] memory) {
    ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ReceiverBridgeAdapterConfigInput[](confirmations);

    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = chainId;
    for (uint256 i = 0; i < confirmations; i++) {
      bridgeAdapters[i] = ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: address(uint160(uint(keccak256(abi.encodePacked(i))))),
        chainIds: chainIds
      });
    }

    return bridgeAdapters;
  }

  function _mockDeliveryAsSuccess(
    address destination,
    address origin,
    uint256 originChainId
  ) internal {
    vm.mockCall(
      destination,
      abi.encodeWithSelector(
        IBaseReceiverPortal.receiveCrossChainMessage.selector,
        origin,
        originChainId,
        MESSAGE
      ),
      abi.encode()
    );
  }
}
