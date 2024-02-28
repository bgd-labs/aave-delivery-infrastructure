// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';
import {ZkEVMAdapterGoerli, ZkEVMAdapterZkEVMGoerli} from '../contract_extensions/ZkEVMAdapterTestnets.sol';

contract DeployZkEVMAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.zkevmAdapter.remoteNetworks;
  }

  function _deployAdapter(
    address crossChainController,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory zkevmConfig = config.adapters.zkevmAdapter;
    require(zkevmConfig.endpoint != address(0), 'ZKEVM endpoint can not be 0');

    address zkevmAdapter;

    if (PathHelpers.isTestNet(config.chainId)) {
      if (config.chainId == TestNetChainIds.ETHEREUM_GOERLI) {
        zkevmAdapter = address(
          new ZkEVMAdapterGoerli(
            crossChainController,
            zkevmConfig.endpoint,
            zkevmConfig.providerGasLimit,
            trustedRemotes
          )
        );
      } else if (config.chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI) {
        zkevmAdapter = address(
          new ZkEVMAdapterZkEVMGoerli(
            crossChainController,
            zkevmConfig.endpoint,
            zkevmConfig.providerGasLimit,
            trustedRemotes
          )
        );
      }
    } else {
      if (config.chainId == ChainIds.ETHEREUM) {
        zkevmAdapter = address(
          new ZkEVMAdapterEthereum(
            crossChainController,
            zkevmConfig.endpoint,
            zkevmConfig.providerGasLimit,
            trustedRemotes
          )
        );
      } else if (config.chainId == ChainIds.POLYGON_ZK_EVM) {
        zkevmAdapter = address(
          new ZkEVMAdapterPolygonZkEVM(
            crossChainController,
            zkevmConfig.endpoint,
            zkevmConfig.providerGasLimit,
            trustedRemotes
          )
        );
      }
    }

    require(zkevmAdapter != address(0), 'ZKEVM adapter needs to be deployed');
    currentAddresses.zkevmAdapter = revisionAddresses.zkevmAdapter = zkevmAdapter;
  }
}

//address constant ZK_EVM_BRIDGE_MAINNET = 0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
//address constant ZK_EVM_BRIDGE_TESTNET = 0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7;
