// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from '../../libs/ChainIds.sol';
import {ZkEVMAdapter} from './ZkEVMAdapter.sol';

contract ZkEVMAdapterPolygonZkEVM is ZkEVMAdapter {
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == ChainIds.ETHEREUM;
  }

  constructor(
    address crossChainController,
    address zkEVMBridge,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ZkEVMAdapter(crossChainController, zkEVMBridge, trustedRemotes) {}
}
