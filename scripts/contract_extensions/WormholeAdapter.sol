// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {WormholeAdapter} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';

/**
 * @title WormholeAdapterTestnet
 * @author BGD Labs
 */
contract WormholeAdapterTestnet is WormholeAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param wormholeRelayer wormhole entry point address
   * @param refundAddress address that will receive left over gas
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address wormholeRelayer,
    address refundAddress,
    TrustedRemotesConfig[] memory trustedRemotes
  ) WormholeAdapter(crossChainController, wormholeRelayer, refundAddress, trustedRemotes) {}

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == uint16(10002)) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId == uint16()) {
      return TestNetChainIds.CELO_ALFAJORES;
    }
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return uint16(10002);
    } else if (infraChainId == TestNetChainIds.CELO_ALFAJORES) {
      return uint16(0);
    }
    return infraChainId;
  }
}
