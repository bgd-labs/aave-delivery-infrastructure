// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {MantleAdapter, IOpAdapter, IMantleAdapter} from '../../src/contracts/adapters/mantle/MantleAdapter.sol';

/**
 * @title MantleAdapterTestnet
 * @author BGD Labs
 */
contract MantleAdapterTestnet is MantleAdapter {
  /**
   * @param params object containing the necessary parameters to initialize the contract
   */
  constructor(IMantleAdapter.MantleParams memory params) MantleAdapter(params) {}

  /// @inheritdoc IOpAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.MANTLE_SEPOLIA;
  }

  /// @inheritdoc IOpAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
