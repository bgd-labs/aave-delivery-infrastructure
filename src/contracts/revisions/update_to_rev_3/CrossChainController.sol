// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainController} from '../../CrossChainController.sol';
import {IReinitialize} from './IReinitialize.sol';

/**
 * @title CrossChainControllerUpgradeRev3
 * @author BGD Labs
 * @notice CrossChainController Revision 3. Contract inheriting from CrossChainController with the addition of re initialization method
 * @dev reinitializer is not used on parent CrossChainController, so this contract is needed to be able to initialize CCC with a new implementation
 * @dev it initializes the new implementation with the addition of the required confirmations for all destination networks supported
 */
contract CrossChainControllerUpgradeRev3 is CrossChainController, IReinitialize {
  /// @inheritdoc IReinitialize
  function initializeRevision(
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external reinitializer(3) {
    _updateOptimalBandwidthByChain(optimalBandwidthByChain);
  }
}
