// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {CrossChainController} from '../CrossChainController.sol';
import {ICrossChainControllerRev2} from './ICrossChainController_Revision_2.sol';

/**
 * @title CrossChainControllerRev2
 * @author BGD Labs
 * @notice CrossChainController Revision 2. Contract inheriting from CrossChainController with the addition of re initialization method
 */
contract CrossChainControllerRev2 is CrossChainController, ICrossChainControllerRev2 {
  /// @inheritdoc ICrossChainControllerRev2
  function initializeRevision() external reinitializer(2) {}
}
