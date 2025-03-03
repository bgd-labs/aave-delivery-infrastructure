// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ICrossChainController} from './interfaces/ICrossChainController.sol';
import {BaseCrossChainController} from './BaseCrossChainController.sol';

/**
 * @title CrossChainController
 * @author BGD Labs
 * @notice CrossChainController contract adopted for usage on the chain where Governance deployed (mainnet in our case)
 */
contract CrossChainController is ICrossChainController, BaseCrossChainController {
  /// @inheritdoc ICrossChainController
  function initialize(
    address owner,
    address guardian,
    ConfirmationInput[] memory initialRequiredConfirmations,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove,
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external initializer {
    _baseInitialize(
      owner,
      guardian,
      initialRequiredConfirmations,
      receiverBridgeAdaptersToAllow,
      forwarderBridgeAdaptersToEnable,
      sendersToApprove,
      optimalBandwidthByChain
    );
  }
}
