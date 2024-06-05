// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter, IBaseAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import './BaseAdapterScript.sol';
import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';
import {ZkEVMAdapterGoerli, ZkEVMAdapterZkEVMGoerli} from '../contract_extensions/ZkEVMAdapterTestnets.sol';

address constant ZK_EVM_BRIDGE_MAINNET = 0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
address constant ZK_EVM_BRIDGE_TESTNET = 0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;

contract Ethereum is BaseAdapterScript {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.POLYGON_ZK_EVM;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.zkevmAdapter = address(
      new ZkEVMAdapterEthereum(
        addresses.crossChainController,
        ZK_EVM_BRIDGE_MAINNET,
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

contract Zkevm is BaseAdapterScript {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.zkevmAdapter = address(
      new ZkEVMAdapterPolygonZkEVM(
        addresses.crossChainController,
        ZK_EVM_BRIDGE_MAINNET,
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

contract Ethereum_testnet is BaseAdapterScript {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.zkevmAdapter = address(
      new ZkEVMAdapterGoerli(
        addresses.crossChainController,
        ZK_EVM_BRIDGE_TESTNET,
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

contract Zkevm_testnet is BaseAdapterScript {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.zkevmAdapter = address(
      new ZkEVMAdapterZkEVMGoerli(
        addresses.crossChainController,
        ZK_EVM_BRIDGE_TESTNET,
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}
