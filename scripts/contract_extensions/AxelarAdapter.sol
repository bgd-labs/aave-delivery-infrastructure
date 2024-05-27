// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from './TestNetChainIds.sol';
import {IAxelarAdapter, AxelarAdapter, Strings} from '../../src/contracts/adapters/axelar/AxelarAdapter.sol';

/**
 * @title AxelarAdapterTestnet
 * @author BGD Labs
 */
contract AxelarAdapterTestnet is AxelarAdapter {
  using Strings for string;

  /**
   * @notice constructor for the Axelar adapter
   * @param gateway address of the axelar gateway endpoint on the current chain where adapter is deployed
   * @param gasService address of the axelar gas service endpoint on the current chain where adapter is deployed
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address gateway,
    address gasService,
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) AxelarAdapter(gateway, gasService, crossChainController, providerGasLimit, trustedRemotes) {}

  /// @inheritdoc IAxelarAdapter
  function axelarNativeToInfraChainId(
    string memory nativeChainId
  ) public pure override returns (uint256) {
    if (nativeChainId.equal('ethereum-sepolia')) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId.equal('Avalanche')) {
      return TestNetChainIds.AVALANCHE_FUJI;
    } else if (nativeChainId.equal('Polygon')) {
      return TestNetChainIds.POLYGON_MUMBAI;
    } else if (nativeChainId.equal('arbitrum-sepolia')) {
      return TestNetChainIds.ARBITRUM_SEPOLIA;
    } else if (nativeChainId.equal('optimism-sepolia')) {
      return TestNetChainIds.OPTIMISM_SEPOLIA;
    } else if (nativeChainId.equal('base-sepolia')) {
      return TestNetChainIds.BASE_SEPOLIA;
    } else if (nativeChainId.equal('binance')) {
      return TestNetChainIds.BNB_TESTNET;
    } else if (nativeChainId.equal('scroll')) {
      return TestNetChainIds.SCROLL_SEPOLIA;
    } else if (nativeChainId.equal('celo')) {
      return TestNetChainIds.CELO_ALFAJORES;
    } else if (nativeChainId.equal('Fantom')) {
      return TestNetChainIds.FANTOM_TESTNET;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IAxelarAdapter
  function axelarInfraToNativeChainId(
    uint256 infraChainId
  ) public pure override returns (string memory) {
    if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return 'Ethereum';
    } else if (infraChainId == TestNetChainIds.AVALANCHE_FUJI) {
      return 'Avalanche';
    } else if (infraChainId == TestNetChainIds.POLYGON_MUMBAI) {
      return 'Polygon';
    } else if (infraChainId == TestNetChainIds.ARBITRUM_SEPOLIA) {
      return 'arbitrum';
    } else if (infraChainId == TestNetChainIds.OPTIMISM_SEPOLIA) {
      return 'optimism';
    } else if (infraChainId == TestNetChainIds.FANTOM_TESTNET) {
      return 'Fantom';
    } else if (infraChainId == TestNetChainIds.BASE_SEPOLIA) {
      return 'base';
    } else if (infraChainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return 'scroll';
    } else if (infraChainId == TestNetChainIds.BNB_TESTNET) {
      return 'binance';
    } else if (infraChainId == TestNetChainIds.CELO_ALFAJORES) {
      return 'celo';
    } else {
      return '';
    }
  }
}
