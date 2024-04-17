// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainController} from '../../CrossChainController.sol';
import {IReinitialize} from './IReinitialize.sol';

/**
 * @title CrossChainControllerUpgradeRev2
 * @author BGD Labs
 * @notice CrossChainController Revision 2. Contract inheriting from CrossChainController with the addition of re initialization method
 * @dev reinitializer is not used on parent CrossChainController, so this contract is needed to be able to initialize CCC with a new implementation
 */
contract CrossChainControllerUpgradeRev2 is CrossChainController, IReinitialize {
  /// @inheritdoc IReinitialize
  function initializeRevision() external reinitializer(2) {}
}
