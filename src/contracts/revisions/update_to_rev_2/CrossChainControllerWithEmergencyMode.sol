// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainControllerWithEmergencyMode} from '../../CrossChainControllerWithEmergencyMode.sol';
import {IReinitialize} from './IReinitialize.sol';

/**
 * @title CrossChainControllerWithEmergencyModeRev2
 * @author BGD Labs
 * @notice Contract inheriting from CrossChainControllerWithEmergencyMode with the addition of re initialization method
 */
contract CrossChainControllerWithEmergencyModeRev2 is
  CrossChainControllerWithEmergencyMode,
  IReinitialize
{
  constructor(address clEmergencyOracle) CrossChainControllerWithEmergencyMode(clEmergencyOracle) {}

  /// @inheritdoc IReinitialize
  function initializeRevision() external reinitializer(2) {}
}
