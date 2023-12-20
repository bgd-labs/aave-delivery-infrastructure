// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ICrossChainReceiver} from '../interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../interfaces/ICrossChainControllerWithEmergencyMode.sol';
import {Envelope} from '../libs/EncodingUtils.sol';

contract GranularGuardianAccessControl {
  address public immutable CROSS_CHAIN_CONTROLLER;

  address internal _retryGuardian;
  address internal _solveEmergencyGuardian;

  event RetryGuardianUpdated(address retryGuardian);
  event SolveEmergencyGuardianUpdated(address solveEmergencyGuardian);

  modifier onlyRetryGuardian() {
    require(msg.sender == _retryGuardian, 'NOT_RETRY_GUARDIAN');
    _;
  }

  modifier onlySolveEmergencyGuardian() {
    require(msg.sender == _solveEmergencyGuardian, 'NOT_SOLVE_EMERGENCY_GUARDIAN');
    _;
  }

  constructor(address retryGuardian, address solveEmergencyGuardian, address crossChainController) {
    require(crossChainController != address(0), 'INVALID_CROSS_CHAIN_CONTROLLER');

    CROSS_CHAIN_CONTROLLER = crossChainController;

    _updateRetryGuardian(retryGuardian);
    _updateSolveEmergencyGuardian(solveEmergencyGuardian);
  }

  function updateSolveEmergencyGuardian(
    address solveEmergencyGuardian
  ) external onlySolveEmergencyGuardian {
    _updateSolveEmergencyGuardian(solveEmergencyGuardian);
  }

  function updateRetryGuardian(address retryGuardian) external onlyRetryGuardian {
    _updateRetryGuardian(retryGuardian);
  }

  function retryEnvelope(
    Envelope memory envelope,
    uint256 gasLimit
  ) external onlyRetryGuardian returns (bytes32) {
    return ICrossChainForwarder(CROSS_CHAIN_CONTROLLER).retryEnvelope(envelope, gasLimit);
  }

  function retryTransaction(
    bytes memory encodedTransaction,
    uint256 gasLimit,
    address[] memory bridgeAdaptersToRetry
  ) external onlyRetryGuardian {
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
  ) external onlySolveEmergencyGuardian {
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

  function _updateRetryGuardian(address retryGuardian) internal {
    require(retryGuardian != address(0), 'INVALID_RETRY_GUARDIAN');

    _retryGuardian = retryGuardian;
    emit RetryGuardianUpdated(retryGuardian);
  }

  function _updateSolveEmergencyGuardian(address solveEmergencyGuardian) internal {
    require(solveEmergencyGuardian != address(0), 'INVALID_SOLVE_EMERGENCY_GUARDIAN');

    _solveEmergencyGuardian = solveEmergencyGuardian;
    emit SolveEmergencyGuardianUpdated(solveEmergencyGuardian);
  }
}
