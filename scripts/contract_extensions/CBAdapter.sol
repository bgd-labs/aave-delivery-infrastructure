// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {CBaseAdapter, IOpAdapter} from '../../src/contracts/adapters/cBase/CBaseAdapter.sol';

/**
 * @title OptimismAdapterTestnet
 * @author BGD Labs
 */
contract CBaseAdapterTestnet is CBaseAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param ovmCrossDomainMessenger optimism entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address ovmCrossDomainMessenger,
    uint256 baseGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) CBaseAdapter(crossChainController, ovmCrossDomainMessenger, baseGasLimit, trustedRemotes) {}

  /// @inheritdoc IOpAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.BASE_GOERLI;
  }

  /// @inheritdoc IOpAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }
}
