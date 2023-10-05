// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {ZkEVMAdapter} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapter.sol';

contract ZkEVMAdapterGoerli is ZkEVMAdapter {
  constructor(
    address crossChainController,
    address zkEVMBridge,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ZkEVMAdapter(crossChainController, zkEVMBridge, trustedRemotes) {}

  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.ETHEREUM_GOERLI;
  }
}

contract ZkEVMAdapterZkEVMGoerli is ZkEVMAdapter {
  constructor(
    address crossChainController,
    address zkEVMBridge,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ZkEVMAdapter(crossChainController, zkEVMBridge, trustedRemotes) {}

  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
  }
}
