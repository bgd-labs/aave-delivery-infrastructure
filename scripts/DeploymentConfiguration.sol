// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import 'forge-std/StdJson.sol';
import {TestNetChainIds} from './contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';

struct ScrollAdapterInfo {
  address inbox;
  uint256[] remoteNetworks;
}

struct CCIPAdapterInfo {
  address ccipRouter;
  address linkToken;
  uint256[] remoteNetworks;
}

struct AdapterConnection {
  bool ccipAdapter;
  uint256 chainId; // for forwarder connection its the destination chain id, for receiver connection its the origin chain id
  bool scrollAdapter;
}

struct AdaptersDeploymentInfo {
  CCIPAdapterInfo ccipAdapter;
  ScrollAdapterInfo scrollAdapter;
}

struct ProxyInfo {
  address deployedAddress;
  string salt;
}

struct ProxyContract {
  ProxyInfo create3;
  ProxyInfo proxyAdmin;
  ProxyInfo transparentProxyFactory;
}

struct CCC {
  address[] approvedSenders;
  address clEmergencyOracle;
  uint8 confirmations;
  uint256 ethFunds;
  address guardian;
  address owner;
  string salt;
}

library DeploymentConfiguration {
  using stdJson for string;

  struct ChainDeploymentInfo {
    AdaptersDeploymentInfo adapters;
    CCC ccc;
    uint256 chainId;
    AdapterConnection[] forwarderConnections;
    ProxyContract[] proxies;
    AdapterConnection[] receiverConnections;
  }

  function _getDeploymentConfiguration(
    string deploymentJsonPath
  ) internal returns (ChainDeploymentInfo[] memory) {
    string memory json = vm.readFile(string(abi.encodePacked(deploymentJsonPath)));

    ChainDeploymentInfo[] memory deploymentConfigs = abi.decode(
      json.parseRaw('.configs'),
      (ChainDeploymentInfo[])
    );

    return deploymentConfigs;
  }

  function _getConfigurationByChainId(
    uint256 chainId,
    string deploymentJsonPath
  ) internal returns (ChainDeploymentInfo memory) {
    ChainDeploymentInfo[] memory deploymentConfigs = _getDeploymentConfiguration(
      deploymentJsonPath
    );
    ChainDeploymentInfo memory deploymentConfig;

    for (uint256 i = 0; i < deploymentConfigs.length; i++) {
      require(deploymentConfigs[i].chainId > 0, 'WRONG_DEPLOYMENT_CONFIGURATION');
      if (deploymentConfigs[i].chainId == chainId) {
        deploymentConfig = deploymentConfigs[i];
        break;
      }
    }

    return deploymentConfig;
  }
}
