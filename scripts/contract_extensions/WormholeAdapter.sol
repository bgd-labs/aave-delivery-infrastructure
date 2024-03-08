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
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  )
    WormholeAdapter(
      crossChainController,
      wormholeRelayer,
      refundAddress,
      providerGasLimit,
      trustedRemotes
    )
  {}

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == 10002) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId == 14) {
      return TestNetChainIds.CELO_ALFAJORES;
    } else if (nativeChainId == 4) {
      return TestNetChainIds.BNB_TESTNET;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return 10002;
    } else if (infraChainId == TestNetChainIds.CELO_ALFAJORES) {
      return 14;
    } else if (infraChainId == TestNetChainIds.BNB_TESTNET) {
      return 4;
    } else {
      return 0;
    }
  }
}
