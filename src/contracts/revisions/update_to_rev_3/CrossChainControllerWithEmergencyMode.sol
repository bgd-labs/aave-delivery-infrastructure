// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainControllerWithEmergencyMode} from '../../CrossChainControllerWithEmergencyMode.sol';
import {IReinitialize} from './IReinitialize.sol';

/**
 * @title CrossChainControllerWithEmergencyModeUpgradeRev3
 * @author BGD Labs
 * @notice Contract inheriting from CrossChainControllerWithEmergencyMode with the addition of re initialization method
 * @dev reinitializer is not used on parent CrossChainController, so this contract is needed to be able to initialize CCC with a new implementation
 * @dev it initializes the new implementation with the addition of the required confirmations for all destination networks supported
 */
contract CrossChainControllerWithEmergencyModeUpgradeRev3 is
  CrossChainControllerWithEmergencyMode,
  IReinitialize
{
  constructor(address clEmergencyOracle) CrossChainControllerWithEmergencyMode(clEmergencyOracle) {}

  /// @inheritdoc IReinitialize
  function initializeRevision(
    RequiredConfirmationsByReceiverChain[] memory requiredConfirmationsByReceiverChain
  ) external reinitializer(3) {
    _updateRequiredConfirmationsForReceiverChain(requiredConfirmationsByReceiverChain);
  }
}
