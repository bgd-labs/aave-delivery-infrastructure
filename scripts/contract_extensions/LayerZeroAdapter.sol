// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ILayerZeroReceiver} from 'solidity-examples/interfaces/ILayerZeroReceiver.sol';
import {ILayerZeroEndpoint} from 'solidity-examples/interfaces/ILayerZeroEndpoint.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';

import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';
import {LayerZeroAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {ILayerZeroAdapter} from '../../src/contracts/adapters/layerZero/ILayerZeroAdapter.sol';
import {TestNetChainIds} from './TestNetChainIds.sol';
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
    TrustedRemotesConfig[] memory originConfigs
  ) LayerZeroAdapter(lzEndpoint, crossChainController, originConfigs) {}

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == uint16(10106)) {
      return TestNetChainIds.AVALANCHE_FUJI;
    } else if (nativeChainId == uint16(10132)) {
      return TestNetChainIds.OPTIMISM_GOERLI;
    } else if (nativeChainId == uint16(10109)) {
      return TestNetChainIds.POLYGON_MUMBAI;
    } else if (nativeChainId == uint16(10143)) {
      return TestNetChainIds.ARBITRUM_GOERLI;
    } else if (nativeChainId == uint16(10112)) {
      return TestNetChainIds.FANTOM_TESTNET;
    } else if (nativeChainId == uint16(10133)) {
      return TestNetChainIds.HARMONY_TESTNET;
    } else if (nativeChainId == uint16(10161)) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (nativeChainId == uint16(10102)) {
      return TestNetChainIds.BNB_TESTNET;
    } else if (nativeChainId == uint16(10151)) {
      return TestNetChainIds.METIS_TESTNET;
    } else if (nativeChainId == uint16(10145)) {
      return TestNetChainIds.GNOSIS_CHIADO;
    } else if (nativeChainId == uint16(10125)) {
      return TestNetChainIds.CELO_ALFAJORES;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == TestNetChainIds.AVALANCHE_FUJI) {
      return uint16(10106);
    } else if (infraChainId == TestNetChainIds.OPTIMISM_GOERLI) {
      return uint16(10132);
    } else if (infraChainId == TestNetChainIds.POLYGON_MUMBAI) {
      return uint16(10109);
    } else if (infraChainId == TestNetChainIds.ARBITRUM_GOERLI) {
      return uint16(10143);
    } else if (infraChainId == TestNetChainIds.FANTOM_TESTNET) {
      return uint16(10112);
    } else if (infraChainId == TestNetChainIds.HARMONY_TESTNET) {
      return uint16(10133);
    } else if (infraChainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return uint16(10161);
    } else if (infraChainId == TestNetChainIds.METIS_TESTNET) {
      return uint16(10151);
    } else if (infraChainId == TestNetChainIds.BNB_TESTNET) {
      return uint16(10102);
    } else if (infraChainId == TestNetChainIds.GNOSIS_CHIADO) {
      return uint16(10145);
    } else if (infraChainId == TestNetChainIds.CELO_ALFAJORES) {
      return uint16(10125);
    } else {
      return uint16(0);
    }
  }
}
