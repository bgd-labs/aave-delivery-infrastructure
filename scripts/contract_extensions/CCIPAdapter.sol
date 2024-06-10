// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'aave-helpers/ChainIds.sol';
import {CCIPAdapter} from '../../src/contracts/adapters/ccip/CCIPAdapter.sol';
import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';

/**
 * @title CCIPAdapterTestnet
 * @author BGD Labs
 */
contract CCIPAdapterTestnet is CCIPAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param ccipRouter ccip entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   * @param linkToken address of the LINK token
   */
  constructor(
    address crossChainController,
    address ccipRouter,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes,
    address linkToken
  ) CCIPAdapter(crossChainController, ccipRouter, providerGasLimit, trustedRemotes, linkToken) {}

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == uint64(16015286601757825753)) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId == uint64(14767482510784806043)) {
      return TestNetChainIds.AVALANCHE_FUJI;
    } else if (nativeChainId == uint64(16281711391670634445)) {
      return TestNetChainIds.POLYGON_AMOY;
    } else if (nativeChainId == uint64(13264668187771770619)) {
      return TestNetChainIds.BNB_TESTNET;
    }
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return uint64(16015286601757825753);
    } else if (infraChainId == TestNetChainIds.AVALANCHE_FUJI) {
      return uint64(14767482510784806043);
    } else if (infraChainId == TestNetChainIds.POLYGON_AMOY) {
      return uint64(12532609583862916517);
    } else if (infraChainId == TestNetChainIds.BNB_TESTNET) {
      return uint64(13264668187771770619);
    }
    return infraChainId;
  }
}
