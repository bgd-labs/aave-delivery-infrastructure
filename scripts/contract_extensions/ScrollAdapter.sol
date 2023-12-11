// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {IOpAdapter, ScrollAdapter} from '../../src/contracts/adapters/scroll/ScrollAdapter.sol';

/**
 * @title OptimismAdapterTestnet
 * @author BGD Labs
 */
contract ScrollAdapterTestnet is ScrollAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param ovmCrossDomainMessenger optimism entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address ovmCrossDomainMessenger,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ScrollAdapter(crossChainController, ovmCrossDomainMessenger, trustedRemotes) {}

  /// @inheritdoc IOpAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.SCROLL_SEPOLIA;
  }

  /// @inheritdoc IOpAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }
}
