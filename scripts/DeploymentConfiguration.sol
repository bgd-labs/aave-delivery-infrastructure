// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import './libs/DecodeHelpers.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';

contract DeploymentConfigurationHelpers is Script {
  function getAddresses(string memory path, Vm vm) external view returns (Addresses memory) {
    string memory json = vm.readFile(path);

    return AddressesHelpers.decodeAddressesJson(json);
  }

  function _getRevisionAddressesByChainId(
    uint256 chainId,
    string memory revision,
    Vm vm
  ) internal view returns (Addresses memory) {
    string memory path = PathHelpers.getNetworkRevisionDeploymentPath(chainId, revision);

    Addresses memory addresses;
    try this.getAddresses(path, vm) returns (Addresses memory decodedAddresses) {
      addresses = decodedAddresses;
    } catch (bytes memory) {}

    return addresses;
  }

  function _getCurrentAddressesByChainId(
    uint256 chainId,
    Vm vm
  ) internal view returns (Addresses memory) {
    string memory path = PathHelpers.getCurrentDeploymentPathByChainId(chainId);

    Addresses memory addresses;
    try this.getAddresses(path, vm) returns (Addresses memory decodedAddresses) {
      addresses = decodedAddresses;
    } catch (bytes memory) {}

    return addresses;
  }

  function _setCurrentDeploymentAddresses(
    uint256 chainId,
    Addresses memory addresses,
    Vm vm
  ) internal {
    string memory path = PathHelpers.getCurrentDeploymentPathByChainId(chainId);

    return AddressesHelpers.saveAddresses(path, addresses, vm);
  }

  function _setRevisionAddresses(
    uint256 chainId,
    string memory revision,
    Addresses memory addresses,
    Vm vm
  ) internal {
    string memory path = PathHelpers.getNetworkRevisionDeploymentPath(chainId, revision);

    return AddressesHelpers.saveAddresses(path, addresses, vm);
  }

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
  ) internal view returns (ChainDeploymentInfo memory) {
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

  function run() public {
    vm.startBroadcast();
    // -----------------------------------------------------------------------------------------------------------------

    // get deployment json path
    string memory key = 'DEPLOYMENT_VERSION';

    // get configuration
    string memory revision = vm.envString(key);
    string memory deploymentConfigJsonPath = PathHelpers.getDeploymentJsonPathByVersion(revision);
    ChainDeploymentInfo[] memory config = _getConfigurationConfig(deploymentConfigJsonPath, vm);

    // ----------------- Persist addresses -----------------------------------------------------------------------------
    for (uint256 i = 0; i < config.length; i++) {
      // fetch current addresses
      Addresses memory currentAddresses = _getCurrentAddressesByChainId(config[i].chainId, vm);
      // fetch revision addresses
      Addresses memory revisionAddresses = _getRevisionAddressesByChainId(
        config[i].chainId,
        revision,
        vm
      );

      // TODO: define how we want to actually deploy.
      // - Multi chain script: we would only need one script and add checks and so on to change networks
      // - Different scripts: maintain makeFile with different script triggers, all of them getting same config. We would
      //   need to add getting specific config for specific chain etc etc. Provably easier to verify and make more granular?
      // _execute(addresses, deploymentConfig);

      // save revision addresses
      _setRevisionAddresses(config[i].chainId, revision, revisionAddresses, vm);
      // save current addresses
      _setCurrentDeploymentAddresses(config[i].chainId, currentAddresses, vm);
    }

    // -----------------------------------------------------------------------------------------------------------------
    vm.stopBroadcast();
  }
}
