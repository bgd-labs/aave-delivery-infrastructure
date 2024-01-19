// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import './libs/DecodeHelpers.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';

contract DeploymentConfigurationHelpers {
  // TODO: correctly import Addresses. this method will be useful to get the correct adapter
  //  function _getAdapterById(
  //    Addresses memory addresses,
  //    Adapters adapter
  //  ) internal view returns (address) {
  //    if (adapter == Adapters.CCIP) {
  //      return addresses.ccipAdapter;
  //    } else if (adapter == Adapters.Scroll_Native) {
  //      return addresses.scrollAdapter;
  //    } else {
  //      return address(0);
  //    }
  //  }

  function _getConfigurationConfig(
    string memory deploymentJsonPath,
    Vm vm
  ) internal view returns (ChainDeploymentInfo[] memory) {
    string memory json = vm.readFile(string(abi.encodePacked(deploymentJsonPath)));

    uint256[] memory deploymentNetworks = DeployJsonDecodeHelpers.decodeChains(json);

    ChainDeploymentInfo[] memory deploymentConfigs = new ChainDeploymentInfo[](
      deploymentNetworks.length
    );

    for (uint256 i = 0; i < deploymentNetworks.length; i++) {
      string memory networkKey = string.concat('.', Strings.toString(deploymentNetworks[i]));
      // first level of the config object
      string memory networkKey1rstLvl = string.concat(networkKey, '.');

      // decode chainId
      deploymentConfigs[i].chainId = DeployJsonDecodeHelpers.decodeChainId(networkKey1rstLvl, json);

      // decode adapters
      deploymentConfigs[i].adapters = DeployJsonDecodeHelpers.decodeAdapters(
        networkKey1rstLvl,
        json
      );

      // decode cross chain controller
      CCC memory ccc;
      try DeployJsonDecodeHelpers.decodeCCC(networkKey1rstLvl, json) returns (
        CCC memory decodedCCC
      ) {
        ccc = decodedCCC;
      } catch (bytes memory) {}

      deploymentConfigs[i].ccc = ccc;

      // decode forwarding connections
      Connections memory forwarderConnections = DeployJsonDecodeHelpers.decodeConnections(
        networkKey1rstLvl,
        'forwarderConnections',
        json
      );
      deploymentConfigs[i].forwarderConnections = forwarderConnections;

      // decode receiving connections
      Connections memory receiverConnections = DeployJsonDecodeHelpers.decodeConnections(
        networkKey1rstLvl,
        'receiverConnections',
        json
      );
      deploymentConfigs[i].receiverConnections = receiverConnections;

      // decoding proxy contracts
      deploymentConfigs[i].proxies = DeployJsonDecodeHelpers.decodeProxies(networkKey1rstLvl, json);
    }

    return deploymentConfigs;
  }

  function _getDeploymentConfigurationByChainId(
    uint256 chainId,
    string memory deploymentJsonPath,
    Vm vm
  ) internal returns (ChainDeploymentInfo memory) {
    ChainDeploymentInfo[] memory deploymentConfigs = _getConfigurationConfig(
      deploymentJsonPath,
      vm
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
