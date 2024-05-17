// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IBaseCrossChainController.sol';

/**
 * @title ICrossChainController
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the ICrossChainControllerMainnet contract
 */
interface ICrossChainController is IBaseCrossChainController {
  /**
   * @notice method called to initialize the proxy
   * @param owner address of the owner of the cross chain controller
   * @param guardian address of the guardian of the cross chain controller
   * @param initialRequiredConfirmations number of confirmations the messages need to be accepted as valid
   * @param receiverBridgeAdaptersToAllow array of addresses of the bridge adapters that can receive messages
   * @param forwarderBridgeAdaptersToEnable array specifying for every bridgeAdapter, the destinations it can have
   * @param sendersToApprove array of addresses to allow as forwarders
   * @param optimalBandwidthByChain array of optimal numbers of bridge adapters to use to send a message to receiver chain
   */
  function initialize(
    address owner,
    address guardian,
    ConfirmationInput[] memory initialRequiredConfirmations,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove,
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external;
}
