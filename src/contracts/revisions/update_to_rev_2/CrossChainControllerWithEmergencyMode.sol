// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainControllerWithEmergencyMode} from '../../CrossChainControllerWithEmergencyMode.sol';
import {IReinitialize} from './IReinitialize.sol';

/**
 * @title CrossChainControllerWithEmergencyModeUpgradeRev2
 * @author BGD Labs
 * @notice Contract inheriting from CrossChainControllerWithEmergencyMode with the addition of re initialization method
 * @dev reinitializer is not used on parent CrossChainController, so this contract is needed to be able to initialize CCC with a new implementation
 */
contract CrossChainControllerWithEmergencyModeUpgradeRev2 is
  CrossChainControllerWithEmergencyMode,
  IReinitialize
{
  constructor(address clEmergencyOracle) CrossChainControllerWithEmergencyMode(clEmergencyOracle) {}

  /// @inheritdoc IReinitialize
  function initializeRevision() external reinitializer(2) {}
}
