// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ICrossChainReceiver} from '../interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../interfaces/ICrossChainControllerWithEmergencyMode.sol';
import {Envelope} from '../libs/EncodingUtils.sol';
//import {AccessControlEnumerable} from 'openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol';
import {AccessControlEnumerable} from './AccessControlEnumerable.sol';

contract GranularGuardianAccessControl is AccessControlEnumerable {
  address public immutable CROSS_CHAIN_CONTROLLER;

  bytes32 public constant SOLVE_EMERGENCY_ROLE = keccak256('SOLVE_EMERGENCY_ROLE');
  bytes32 public constant RETRY_ROLE = keccak256('RETRY_ROLE');

  constructor(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address crossChainController
  ) {
    require(crossChainController != address(0), 'INVALID_CROSS_CHAIN_CONTROLLER');

    CROSS_CHAIN_CONTROLLER = crossChainController;

    _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    _setRoleAdmin(SOLVE_EMERGENCY_ROLE, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(RETRY_ROLE, DEFAULT_ADMIN_ROLE);

    _grantRole(SOLVE_EMERGENCY_ROLE, solveEmergencyGuardian);
    _grantRole(RETRY_ROLE, retryGuardian);
  }

  function retryEnvelope(
    Envelope memory envelope,
    uint256 gasLimit
  ) external onlyRole(RETRY_ROLE) returns (bytes32) {
    return ICrossChainForwarder(CROSS_CHAIN_CONTROLLER).retryEnvelope(envelope, gasLimit);
  }

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

  function solveEmergency(
    ICrossChainReceiver.ConfirmationInput[] memory newConfirmations,
    ICrossChainReceiver.ValidityTimestampInput[] memory newValidityTimestamp,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToDisallow,
    address[] memory sendersToApprove,
    address[] memory sendersToRemove,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    ICrossChainForwarder.BridgeAdapterToDisable[] memory forwarderBridgeAdaptersToDisable
  ) external onlyRole(SOLVE_EMERGENCY_ROLE) {
    ICrossChainControllerWithEmergencyMode(CROSS_CHAIN_CONTROLLER).solveEmergency(
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
}
