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
  function initializeRevision() external reinitializer(3) {
    RequiredConfirmationsByReceiverChain[]
      memory requiredConfirmationsByReceiverChain = new RequiredConfirmationsByReceiverChain[](10);
    // Polygon
    requiredConfirmationsByReceiverChain[0].chainId = 137;
    requiredConfirmationsByReceiverChain[0].requiredConfirmations = 2;
    // Avalanche
    requiredConfirmationsByReceiverChain[1].chainId = 43114;
    requiredConfirmationsByReceiverChain[1].requiredConfirmations = 2;
    // Arbitrum
    requiredConfirmationsByReceiverChain[2].chainId = 42161;
    requiredConfirmationsByReceiverChain[2].requiredConfirmations = 1;
    // Optimism
    requiredConfirmationsByReceiverChain[3].chainId = 10;
    requiredConfirmationsByReceiverChain[3].requiredConfirmations = 1;
    // Metis
    requiredConfirmationsByReceiverChain[4].chainId = 1088;
    requiredConfirmationsByReceiverChain[4].requiredConfirmations = 1;
    // Binance
    requiredConfirmationsByReceiverChain[5].chainId = 56;
    requiredConfirmationsByReceiverChain[5].requiredConfirmations = 2;
    // Base
    requiredConfirmationsByReceiverChain[6].chainId = 8453;
    requiredConfirmationsByReceiverChain[6].requiredConfirmations = 1;
    // Gnosis
    requiredConfirmationsByReceiverChain[7].chainId = 100;
    requiredConfirmationsByReceiverChain[7].requiredConfirmations = 2;
    // Scroll
    requiredConfirmationsByReceiverChain[8].chainId = 534352;
    requiredConfirmationsByReceiverChain[8].requiredConfirmations = 1;
    // Ethereum
    requiredConfirmationsByReceiverChain[9].chainId = 1;
    requiredConfirmationsByReceiverChain[9].requiredConfirmations = 1; // TODO: provably no need to set this one

    _updateRequiredConfirmationsForReceiverChain(requiredConfirmationsByReceiverChain);
  }
}
