// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from '../../libs/ChainIds.sol';
import {ZkEVMAdapter} from './ZkEVMAdapter.sol';

contract ZkEVMAdapterEthereum is ZkEVMAdapter {
  // Overrides to use ZkEVM chain id, which is Ethereum's destination
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == ChainIds.POLYGON_ZK_EVM;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param zkEVMBridge address of the zkEVMBridge that will be used to send/receive messages to the root/child chain
   * @param baseGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address zkEVMBridge,
    uint256 baseGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) ZkEVMAdapter(crossChainController, zkEVMBridge, baseGasLimit, trustedRemotes) {}
}
