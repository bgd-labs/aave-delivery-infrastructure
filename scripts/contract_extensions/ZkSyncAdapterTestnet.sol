// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'aave-helpers/ChainIds.sol';
import {IZkSyncAdapter, ZkSyncAdapter} from '../../src/contracts/adapters/zkSync/ZkSyncAdapter.sol';

contract ZkSyncAdapterTestnet is ZkSyncAdapter {
  constructor(
    address crossChainController,
    address mailBox,
    address refundAddress,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ZkSyncAdapter(crossChainController, mailBox, refundAddress, providerGasLimit, trustedRemotes) {}

  /// @inheritdoc IZkSyncAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.ZK_SYNC_SEPOLIA;
  }

  /// @inheritdoc IZkSyncAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
