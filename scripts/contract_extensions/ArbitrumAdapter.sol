// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {IArbAdapter, ArbAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';

/**
 * @title ArbitrumAdapterTestnet
 * @author BGD Labs
 */
contract ArbitrumAdapterTestnet is ArbAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param inbox arbitrum entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address inbox,
    address destinationCCC,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ArbAdapter(crossChainController, inbox, destinationCCC, trustedRemotes) {}

  /// @inheritdoc IArbAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.ARBITRUM_GOERLI;
  }

  /// @inheritdoc IArbAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }
}
