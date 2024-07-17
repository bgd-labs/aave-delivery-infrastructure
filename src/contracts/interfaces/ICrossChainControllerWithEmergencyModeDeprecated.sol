// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IBaseCrossChainController.sol';
import '../emergency/interfaces/IEmergencyConsumer.sol';

/**
 * @title ICrossChainControllerWithEmergencyModeRev2
 * @author BGD Labs. Interface containing the solveEmergency interface of the CrossChainController of Revision 2 or older
 */
interface ICrossChainControllerWithEmergencyModeDeprecated is
  IBaseCrossChainController,
  IEmergencyConsumer
{
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
   */
  function solveEmergency(
    ConfirmationInput[] memory newConfirmations,
    ValidityTimestampInput[] memory newValidityTimestamp,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable
  ) external;
}
