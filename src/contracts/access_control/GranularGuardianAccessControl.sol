// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ICrossChainForwarder} from '../interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../interfaces/ICrossChainControllerWithEmergencyMode.sol';
import {IGranularGuardianAccessControl, Envelope, ICrossChainReceiver} from './IGranularGuardianAccessControl.sol';
import {AccessControlEnumerable} from 'openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol';
import {IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {ICrossChainControllerWithEmergencyModeDeprecated} from '../interfaces/ICrossChainControllerWithEmergencyModeDeprecated.sol';

/**
 * @title GranularGuardianAccessControl
 * @author BGD Labs
 * @notice Contract to manage a granular access to the methods safeguarded by guardian on CrossChainController
 */
contract GranularGuardianAccessControl is AccessControlEnumerable, IGranularGuardianAccessControl {
  /// @inheritdoc IGranularGuardianAccessControl
  address public immutable CROSS_CHAIN_CONTROLLER;

  /// @inheritdoc IGranularGuardianAccessControl
  bytes32 public constant SOLVE_EMERGENCY_ROLE = keccak256('SOLVE_EMERGENCY_ROLE');

  /// @inheritdoc IGranularGuardianAccessControl
  bytes32 public constant RETRY_ROLE = keccak256('RETRY_ROLE');

  /**
   * @param initialGuardians object with the initial guardians to assign the roles to
   * @param crossChainController address of the CrossChainController
   */
  constructor(InitialGuardians memory initialGuardians, address crossChainController) {
    if (crossChainController == address(0)) {
      revert CrossChainControllerCantBe0();
    }
    if (initialGuardians.defaultAdmin == address(0)) {
      revert DefaultAdminCantBe0();
    }

    CROSS_CHAIN_CONTROLLER = crossChainController;

    _grantRole(DEFAULT_ADMIN_ROLE, initialGuardians.defaultAdmin);

    if (initialGuardians.solveEmergencyGuardian != address(0)) {
      _grantRole(SOLVE_EMERGENCY_ROLE, initialGuardians.solveEmergencyGuardian);
    }
    if (initialGuardians.retryGuardian != address(0)) {
      _grantRole(RETRY_ROLE, initialGuardians.retryGuardian);
    }
  }

  /// @inheritdoc IGranularGuardianAccessControl
  function retryEnvelope(
    Envelope memory envelope,
    uint256 gasLimit
  ) external onlyRole(RETRY_ROLE) returns (bytes32) {
    return ICrossChainForwarder(CROSS_CHAIN_CONTROLLER).retryEnvelope(envelope, gasLimit);
  }

  /// @inheritdoc IGranularGuardianAccessControl
  function retryTransaction(
    bytes memory encodedTransaction,
    uint256 gasLimit,
    address[] memory bridgeAdaptersToRetry
  ) external onlyRole(RETRY_ROLE) {
    ICrossChainForwarder(CROSS_CHAIN_CONTROLLER).retryTransaction(
      encodedTransaction,
      gasLimit,
      bridgeAdaptersToRetry
    );
  }

  /// @inheritdoc IGranularGuardianAccessControl
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
  ) external onlyRole(SOLVE_EMERGENCY_ROLE) {
    ICrossChainControllerWithEmergencyMode(CROSS_CHAIN_CONTROLLER).solveEmergency(
      newConfirmations,
      newValidityTimestamp,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable,
      optimalBandwidthByChain
    );
  }

  /// @inheritdoc IGranularGuardianAccessControl
  function solveEmergencyDeprecated(
    ICrossChainReceiver.ConfirmationInput[] memory newConfirmations,
    ICrossChainReceiver.ValidityTimestampInput[] memory newValidityTimestamp,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    ICrossChainForwarder.BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable
  ) external onlyRole(SOLVE_EMERGENCY_ROLE) {
    ICrossChainControllerWithEmergencyModeDeprecated(CROSS_CHAIN_CONTROLLER).solveEmergency(
      newConfirmations,
      newValidityTimestamp,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable
    );
  }

  /// @inheritdoc IGranularGuardianAccessControl
  function updateGuardian(
    address newCrossChainControllerGuardian
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    if (newCrossChainControllerGuardian == address(0)) {
      revert NewGuardianCantBe0();
    }
    IWithGuardian(CROSS_CHAIN_CONTROLLER).updateGuardian(newCrossChainControllerGuardian);
  }
}
