// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Envelope} from '../libs/EncodingUtils.sol';
import {ICrossChainReceiver} from '../interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../interfaces/ICrossChainForwarder.sol';

/**
 * @title IGranularGuardianAccessControl
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the GranularGuardianAccessControl contract
 */
interface IGranularGuardianAccessControl {
  /// @dev default admin address can not be address 0
  error DefaultAdminCantBe0();

  /// @dev CrossChainController address can not be address 0
  error CrossChainControllerCantBe0();

  /// @dev new Guardian address can not be address 0
  error NewGuardianCantBe0();

  /**
   * @param defaultAdmin address that will have control of the default admin
   * @param retryGuardian address to be added to the retry role
   * @param solveEmergencyGuardian address to be added to the solve emergency role
   */
  struct InitialGuardians {
    address defaultAdmin;
    address retryGuardian;
    address solveEmergencyGuardian;
  }

  /**
   * @notice method called to re forward a previously sent envelope.
             This method is only callable by the accounts holding the RETRY_ROLE role
   * @param envelope the Envelope type data
   * @param gasLimit gas cost on receiving side of the message
   * @return the transaction id that has the retried envelope
   * @dev This method will send an existing Envelope using a new Transaction.
   * @dev This method should be used when the intention is to send the Envelope as if it was a new message. This way on
          the Receiver side it will start from 0 to count for the required confirmations. (usual use case would be for
          when an envelope has been invalidated on Receiver side, and needs to be retried as a new message)
   */
  function retryEnvelope(Envelope memory envelope, uint256 gasLimit) external returns (bytes32);

  /**
   * @notice method to retry forwarding an already forwarded transaction.
             This method is only callable by the accounts holding the RETRY_ROLE role
   * @param encodedTransaction the encoded Transaction data
   * @param gasLimit limit of gas to spend on forwarding per bridge
   * @param bridgeAdaptersToRetry list of bridge adapters to be used for the transaction forwarding retry
   * @dev This method will send an existing Transaction with its Envelope to the specified adapters.
   * @dev Should be used when some of the bridges on the initial forwarding did not work (out of gas),
          and we want the Transaction with Envelope to still account for the required confirmations on the Receiver side
   */
  function retryTransaction(
    bytes memory encodedTransaction,
    uint256 gasLimit,
    address[] memory bridgeAdaptersToRetry
  ) external;

  /**
   * @notice method to solve an emergency. This method is only callable by the accounts holding the SOLVE_EMERGENCY_ROLE role
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
    ICrossChainReceiver.ConfirmationInput[] memory newConfirmations,
    ICrossChainReceiver.ValidityTimestampInput[] memory newValidityTimestamp,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    ICrossChainForwarder.BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable,
    ICrossChainForwarder.OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external;

  /**
   * @notice method to solve an emergency on a CrossChainController with Revision 2 or older interface. This method is only callable by the accounts holding the SOLVE_EMERGENCY_ROLE role
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
  function solveEmergencyDeprecated(
    ICrossChainReceiver.ConfirmationInput[] memory newConfirmations,
    ICrossChainReceiver.ValidityTimestampInput[] memory newValidityTimestamp,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    ICrossChainForwarder.BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable
  ) external;

  /**
   * @notice method to update the CrossChainController guardian when this contract has been set as guardian
   */
  function updateGuardian(address newCrossChainControllerGuardian) external;

  /**
   * @notice method to get the address of the CrossChainController where the contract points to
   * @return the address of the CrossChainController
   */
  function CROSS_CHAIN_CONTROLLER() external view returns (address);

  /**
   * @notice method to get the solve emergency role
   * @return the solve emergency role id
   */
  function SOLVE_EMERGENCY_ROLE() external view returns (bytes32);

  /**
   * @notice method to get the retry role
   * @return the retry role id
   */
  function RETRY_ROLE() external view returns (bytes32);
}
