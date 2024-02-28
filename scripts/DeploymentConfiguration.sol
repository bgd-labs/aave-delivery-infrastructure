// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console.sol';
import './libs/DecodeHelpers.sol';
import './libs/AddressBookHelper.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';

abstract contract DeploymentConfigurationBaseScript is DeployJsonDecodeHelpers, Script {
  function getAddresses(string memory path, Vm vm) external view returns (Addresses memory) {
    string memory json = vm.readFile(path);

    return AddressesHelpers.decodeAddressesJson(json);
  }

  function _getCrossChainController(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    uint256 chainId
  ) internal pure returns (address) {
    if (revisionAddresses.crossChainController != address(0)) {
      return revisionAddresses.crossChainController;
    } else if (AddressBookMiscHelper.getCrossChainController(chainId) != address(0)) {
      return AddressBookMiscHelper.getCrossChainController(chainId);
    } else if (currentAddresses.crossChainController != address(0)) {
      return currentAddresses.crossChainController;
    } else {
      return address(0);
    }
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
    string memory revision,
    Vm vm
  ) internal view returns (ChainDeploymentInfo[] memory) {
    string memory json = vm.readFile(string(abi.encodePacked(deploymentJsonPath)));

    string[] memory deploymentNetworks = decodeChains(json);

    ChainDeploymentInfo[] memory deploymentConfigs = new ChainDeploymentInfo[](
      deploymentNetworks.length
    );

    for (uint256 i = 0; i < deploymentNetworks.length; i++) {
      deploymentConfigs[i].revision = revision;

      string memory networkKey = string.concat('.', deploymentNetworks[i]);
      // first level of the config object
      string memory networkKey1rstLvl = string.concat(networkKey, '.');

      // decode chainId
      deploymentConfigs[i].chainId = decodeChainId(networkKey1rstLvl, json);

      // decode adapters
      deploymentConfigs[i].adapters = decodeAdapters(networkKey1rstLvl, json);

      // decode cross chain controller
      CCC memory ccc;
      try this.decodeCCC(networkKey1rstLvl, json) returns (CCC memory decodedCCC) {
        ccc = decodedCCC;
      } catch (bytes memory) {}

      deploymentConfigs[i].ccc = ccc;

      // decode forwarding connections
      Connections memory forwarderConnections = decodeConnections(
        networkKey1rstLvl,
        'forwarderConnections',
        json
      );
      deploymentConfigs[i].forwarderConnections = forwarderConnections;

      // decode receiving connections
      Connections memory receiverConnections = decodeConnections(
        networkKey1rstLvl,
        'receiverConnections',
        json
      );
      deploymentConfigs[i].receiverConnections = receiverConnections;

      // decoding proxy contracts
      deploymentConfigs[i].proxies = decodeProxies(networkKey1rstLvl, json);

      // decode emergency registry
      deploymentConfigs[i].emergencyRegistry = decodeEmergencyRegistry(networkKey1rstLvl, json);
    }

    return deploymentConfigs;
  }

  function _getDeploymentConfigurationByChainId(
    uint256 chainId,
    string memory deploymentJsonPath,
    string memory revision,
    Vm vm
  ) internal view returns (ChainDeploymentInfo memory) {
    ChainDeploymentInfo[] memory deploymentConfigs = _getConfigurationConfig(
      deploymentJsonPath,
      revision,
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

  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal virtual;

  function run() public {
    // get deployment json path
    string memory key = 'DEPLOYMENT_VERSION';

    // get chainId
    uint256 chainId = PathHelpers.getChainIdByName(vm.envString('CHAIN_ID'));

    // get configuration
    string memory revision = vm.envString(key);
    string memory deploymentConfigJsonPath = PathHelpers.getDeploymentJsonPathByVersion(revision);
    ChainDeploymentInfo[] memory config = _getConfigurationConfig(
      deploymentConfigJsonPath,
      revision,
      vm
    );

    // ----------------- Persist addresses -----------------------------------------------------------------------------
    for (uint256 i = 0; i < config.length; i++) {
      // the chain id to deploy to comes from config json, from makefile
      if (config[i].chainId == chainId) {
        vm.startBroadcast();
        // ---------------------------------------------------------------------------------------------------------------

        // fetch current addresses
        Addresses memory currentAddresses = _getCurrentAddressesByChainId(config[i].chainId, vm);
        // fetch revision addresses
        Addresses memory revisionAddresses = _getRevisionAddressesByChainId(
          config[i].chainId,
          revision,
          vm
        );

        // method to implement the different deployment logic
        _execute(currentAddresses, revisionAddresses, config[i]);

        // update global params
        currentAddresses.chainId = revisionAddresses.chainId = config[i].chainId;
        (uint256 numRevision, ) = StringUtils.strToUint(revision);
        // TODO: this conflicts with the way we execute scripts in make file. Not sure what to do with it
        //      require(
        //        !error && currentAddresses.version < numRevision,
        //        'New revision must be strictly bigger than current version'
        //      );
        currentAddresses.version = revisionAddresses.version = numRevision;

        // save revision addresses
        _setRevisionAddresses(config[i].chainId, revision, revisionAddresses, vm);
        // save current addresses
        _setCurrentDeploymentAddresses(config[i].chainId, currentAddresses, vm);

        // ---------------------------------------------------------------------------------------------------------------
        vm.stopBroadcast();
      }
    }
  }
}
