// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';
import {LayerZeroAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {ILayerZeroAdapter} from '../../src/contracts/adapters/layerZero/ILayerZeroAdapter.sol';
import {TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';

/**
 * @title LayerZeroAdapterTestnet
 * @author BGD Labs
 */
contract LayerZeroAdapterTestnet is LayerZeroAdapter {
  /**
   * @notice constructor for the Layer Zero adapter
   * @param lzEndpoint address of the layer zero endpoint on the current chain where adapter is deployed
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param originConfigs array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address lzEndpoint,
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory originConfigs
  ) LayerZeroAdapter(lzEndpoint, crossChainController, providerGasLimit, originConfigs) {}

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == 40106) {
      return TestNetChainIds.AVALANCHE_FUJI;
    } else if (nativeChainId == 40232) {
      return TestNetChainIds.OPTIMISM_SEPOLIA;
    } else if (nativeChainId == 40267) {
      return TestNetChainIds.POLYGON_AMOY;
    } else if (nativeChainId == 40231) {
      return TestNetChainIds.ARBITRUM_SEPOLIA;
    } else if (nativeChainId == 40112) {
      return TestNetChainIds.FANTOM_TESTNET;
    } else if (nativeChainId == 40161) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId == 40102) {
      return TestNetChainIds.BNB_TESTNET;
    } else if (nativeChainId == 40151) {
      return TestNetChainIds.METIS_TESTNET;
    } else if (nativeChainId == 40145) {
      return TestNetChainIds.GNOSIS_CHIADO;
    } else if (nativeChainId == 40125) {
      return TestNetChainIds.CELO_ALFAJORES;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == TestNetChainIds.AVALANCHE_FUJI) {
      return 40106;
    } else if (infraChainId == TestNetChainIds.OPTIMISM_SEPOLIA) {
      return 40232;
    } else if (infraChainId == TestNetChainIds.POLYGON_AMOY) {
      return 40267;
    } else if (infraChainId == TestNetChainIds.ARBITRUM_SEPOLIA) {
      return 40231;
    } else if (infraChainId == TestNetChainIds.FANTOM_TESTNET) {
      return 40112;
    } else if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return 40161;
    } else if (infraChainId == TestNetChainIds.METIS_TESTNET) {
      return 40151;
    } else if (infraChainId == TestNetChainIds.BNB_TESTNET) {
      return 40102;
    } else if (infraChainId == TestNetChainIds.GNOSIS_CHIADO) {
      return 40145;
    } else if (infraChainId == TestNetChainIds.CELO_ALFAJORES) {
      return 40125;
    } else {
      return uint16(0);
    }
  }
}
