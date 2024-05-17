// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IBaseCrossChainController.sol';
import '../emergency/interfaces/IEmergencyConsumer.sol';

/**
 * @title ICrossChainControllerWithEmergencyMode
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the CrossChainControllerWithEmergencyMode contract
 */
interface ICrossChainControllerWithEmergencyMode is IBaseCrossChainController, IEmergencyConsumer {
  /**
   * @notice method called to initialize the proxy
   * @param owner address of the owner of the cross chain controller
   * @param guardian address of the guardian of the cross chain controller
   * @param clEmergencyOracle address of the chainlink emergency oracle
   * @param initialRequiredConfirmations number of confirmations the messages need to be accepted as valid
   * @param receiverBridgeAdaptersToAllow array of addresses of the bridge adapters that can receive messages
   * @param forwarderBridgeAdaptersToEnable array specifying for every bridgeAdapter, the destinations it can have
   * @param sendersToApprove array of addresses to allow as forwarders
   * @param optimalBandwidthByChain array of optimal numbers of bridge adapters to use to send a message to receiver chain
   */
  function initialize(
    address owner,
    address guardian,
    address clEmergencyOracle,
    ConfirmationInput[] memory initialRequiredConfirmations,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove,
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external;

  /**
   * @notice method to solve an emergency. This method is only callable by the guardian
   * @param newConfirmations number of confirmations necessary for a message to be routed to destination
   * @param newValidityTimestamp timestamp in seconds indicating the point to where not confirmed messages will be
   *        invalidated.
   * @param receiverBridgeAdaptersToAllow list of bridge adapter addresses to be allowed to receive messages
   * @param receiverBridgeAdaptersToDisallow list of bridge adapter addresses to be disallowed
   * @param sendersToApprove list of addresses to be approved as senders
   * @param sendersToRemove list of sender addresses to be removed
   * @param forwarderBridgeAdaptersToEnable list of bridge adapters to be enabled to send messages
   * @param forwarderBridgeAdaptersToDisable list of bridge adapters to be disabled
   * @param optimalBandwidthByChain array of optimal numbers of bridge adapters to use to send a message to receiver chain
   */
  function solveEmergency(
    ConfirmationInput[] memory newConfirmations,
    ValidityTimestampInput[] memory newValidityTimestamp,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable,
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external;
}
