// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainControllerWithEmergencyMode} from '../CrossChainControllerWithEmergencyMode.sol';
import {ICrossChainControllerRev2} from './ICrossChainController_Revision_2.sol';

/**
 * @title CrossChainControllerWithEmergencyModeRev2
 * @author BGD Labs
 * @notice Contract inheriting from CrossChainControllerWithEmergencyMode with the addition of re initialization method
 */
contract CrossChainControllerWithEmergencyModeRev2 is
  CrossChainControllerWithEmergencyMode,
  ICrossChainControllerRev2
{
  constructor(address clEmergencyOracle) CrossChainControllerWithEmergencyMode(clEmergencyOracle) {}

  /// @inheritdoc ICrossChainControllerRev2
  function initializeRevision() external reinitializer(2) {}
}
