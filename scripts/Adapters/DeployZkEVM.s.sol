// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter, IBaseAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import './BaseAdapterScript.sol';
import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';

library Addresses {
  address internal constant ZK_EVM_BRIDGE_MAINNET = 0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
  address internal constant ZK_EVM_BRIDGE_TESTNET = 0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;
}

contract DeployEthereum is BaseAdapterScript {
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
    IBaseAdapter.TrustedRemotesConfig[] memory configs;
    new ZkEVMAdapterEthereum(address(0), Addresses.ZK_EVM_BRIDGE_MAINNET, configs);
  }
}

contract DeployZkEVM is BaseAdapterScript {
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
    IBaseAdapter.TrustedRemotesConfig[] memory configs;
    new ZkEVMAdapterPolygonZkEVM(address(0), Addresses.ZK_EVM_BRIDGE_MAINNET, configs);
  }
}

contract DeployGoerli is BaseAdapterScript {
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
    IBaseAdapter.TrustedRemotesConfig[] memory configs;
    new ZkEVMAdapterEthereum(address(0), Addresses.ZK_EVM_BRIDGE_TESTNET, configs);
  }
}

contract DeployZkEVMGoerli is BaseAdapterScript {
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
    IBaseAdapter.TrustedRemotesConfig[] memory configs;
    new ZkEVMAdapterPolygonZkEVM(address(0), Addresses.ZK_EVM_BRIDGE_TESTNET, configs);
  }
}
