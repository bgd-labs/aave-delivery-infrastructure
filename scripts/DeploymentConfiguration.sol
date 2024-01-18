// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import 'forge-std/StdJson.sol';
import {TestNetChainIds} from './contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';
import {CCIPAdapter} from '../src/contracts/adapters/ccip/CCIPAdapter.sol';

import './BaseScriptV3.sol';

struct ScrollAdapterInfo {
  address inbox;
  uint256[] remoteNetworks;
}

struct CCIPAdapterInfo {
  address ccipRouter;
  address linkToken;
  uint256[] remoteNetworks;
}

struct Connections {
  uint256[] chainIds;
  uint256[] ethereum;
  uint256[] avalanche;
  uint256[] polygon;
  uint256[] arbitrum;
  uint256[] optimism;
  uint256[] polygon_zkevm;
  uint256[] binance;
  uint256[] metis;
  uint256[] gnosis;
  uint256[] scroll;
  uint256[] base;
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

struct ChainDeploymentInfo {
  AdaptersDeploymentInfo adapters;
  CCC ccc;
  uint256 chainId;
  Connections forwarderConnections;
  //  ProxyContract[] proxies;
  Connections receiverConnections;
}

enum Adapters {
  Null_Adapter,
  CCIP,
  Arbitrum_Native,
  Optimism_Native,
  Polygon_Native,
  Gnosis_Native,
  Metis_Native,
  LayerZero,
  Hyperlane,
  Scroll_Native,
  Polygon_ZkEvm_Native,
  Base_Native
}

contract DeploymentConfigurationHelpers {
  using stdJson for string;
  using StringUtils for string;

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

  function _getChainNameById(uint256 chainId) internal pure returns (string memory) {
    if (chainId == ChainIds.ETHEREUM) {
      return 'ethereum';
    } else if (chainId == ChainIds.POLYGON) {
      return 'polygon';
    } else if (chainId == ChainIds.AVALANCHE) {
      return 'avalanche';
    } else if (chainId == ChainIds.ARBITRUM) {
      return 'arbitrum';
    } else if (chainId == ChainIds.OPTIMISM) {
      return 'optimism';
    } else if (chainId == ChainIds.METIS) {
      return 'metis';
    } else if (chainId == ChainIds.BNB) {
      return 'binance';
    } else if (chainId == ChainIds.BASE) {
      return 'base';
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return 'polygon_zkevm';
    } else if (chainId == ChainIds.GNOSIS) {
      return 'gnosis';
    } else if (chainId == ChainIds.SCROLL) {
      return 'scroll';
    }

    if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return 'ethereum_sepolia';
    } else if (chainId == TestNetChainIds.ETHEREUM_GOERLI) {
      return 'ethereum_goerli';
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return 'polygon_mumbai';
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return 'avalanche_fuji';
    } else if (chainId == TestNetChainIds.ARBITRUM_GOERLI) {
      return 'arbitrum_goerli';
    } else if (chainId == TestNetChainIds.OPTIMISM_GOERLI) {
      return 'optimism_goerli';
    } else if (chainId == TestNetChainIds.METIS_TESTNET) {
      return 'metis_test';
    } else if (chainId == TestNetChainIds.BNB_TESTNET) {
      return 'binance_test';
    } else if (chainId == TestNetChainIds.BASE_GOERLI) {
      return 'base_goerli';
    } else if (chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI) {
      return 'polygon_zkevm_goerli';
    } else if (chainId == TestNetChainIds.GNOSIS_CHIADO) {
      return 'gnosis_chiado';
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return 'scroll_sepolia';
    } else {
      revert('chain id is not supported');
    }
  }

  function _getDeploymentJsonPathByVersion(
    string memory version
  ) internal pure returns (string memory) {
    string memory path = string.concat(
      './deployments/deployment_configurations/deploymentConfigs_',
      version
    );
    return string.concat(path, '.json');
  }

  function _getCurrentDeploymentPathByChainId(
    uint256 chainId
  ) internal view returns (string memory) {
    string memory path = string.concat('./deployments/current/', _getChainNameById(chainId));
    return string.concat(path, '.json');
  }

  function _getNetworkRevisionDeploymentPath(
    uint256 chainId,
    string memory revision
  ) internal view returns (string memory) {
    string memory networkName = string.concat(_getChainNameById(chainId), '_');
    string memory networkWithRevision = string.concat(networkName, revision);
    string memory path = string.concat('./deployments/revisions/', networkWithRevision);
    return string.concat(path, '.json');
  }

  function decodeAddress(string memory path, string memory json) external view returns (address) {
    return abi.decode(json.parseRaw(path), (address));
  }

  function decodeUint256(string memory path, string memory json) external view returns (uint256) {
    return abi.decode(json.parseRaw(path), (uint256));
  }

  function decodeUint256Array(
    string memory path,
    string memory json
  ) external view returns (uint256[] memory) {
    return abi.decode(json.parseRaw(path), (uint256[]));
  }

  // TODO: should this be made external to follow ccip pattern?? or should ccip follow scroll pattern of internal params?
  function _decodeScrollAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (ScrollAdapterInfo memory) {
    string memory scrollAdapterKey = string.concat(adapterKey, 'scrollAdapter.');
    address inbox;
    // if inbox does not exist in json, instead of throwing we return address 0
    // TODO: should this be done on all cases? or in an object level?
    try this.decodeAddress(string.concat(scrollAdapterKey, 'inbox'), json) returns (
      address decodedInbox
    ) {
      inbox = decodedInbox;
    } catch (bytes memory) {}

    ScrollAdapterInfo memory scrollAdapter = ScrollAdapterInfo({
      inbox: inbox,
      remoteNetworks: abi.decode(
        json.parseRaw(string.concat(scrollAdapterKey, 'remoteNetworks')),
        (uint256[])
      )
    });

    return scrollAdapter;
  }

  function decodeCCIPAdapter(
    string memory adapterKey,
    string memory json
  ) external view returns (CCIPAdapterInfo memory) {
    string memory ccipAdapterKey = string.concat(adapterKey, 'ccipAdapter.');
    CCIPAdapterInfo memory ccipAdapter = CCIPAdapterInfo({
      ccipRouter: abi.decode(json.parseRaw(string.concat(ccipAdapterKey, 'ccipRouter')), (address)),
      linkToken: abi.decode(json.parseRaw(string.concat(ccipAdapterKey, 'linkToken')), (address)),
      remoteNetworks: abi.decode(
        json.parseRaw(string.concat(ccipAdapterKey, 'remoteNetworks')),
        (uint256[])
      )
    });

    return ccipAdapter;
  }

  function _decodeAdapters(
    string memory firstLvlKey,
    string memory json
  ) internal view returns (AdaptersDeploymentInfo memory) {
    string memory adaptersKey = string.concat(firstLvlKey, 'adapters.');

    CCIPAdapterInfo memory ccipAdapter;

    // if ccipAdapter does not exist on json, we return empty object. TODO: is it fine to do at object lvl or should this be done at param lvl
    try this.decodeCCIPAdapter(adaptersKey, json) returns (
      CCIPAdapterInfo memory decodedCCIPAdapter
    ) {
      ccipAdapter = decodedCCIPAdapter;
    } catch (bytes memory) {}

    AdaptersDeploymentInfo memory adapters = AdaptersDeploymentInfo({
      scrollAdapter: _decodeScrollAdapter(adaptersKey, json),
      ccipAdapter: ccipAdapter
    });

    return adapters;
  }

  function decodeCCC(
    string memory firstLvlKey,
    string memory json
  ) external view returns (CCC memory) {
    string memory cccKey = string.concat(firstLvlKey, 'ccc.');
    CCC memory ccc = CCC({
      approvedSenders: abi.decode(
        json.parseRaw(string.concat(cccKey, 'approvedSenders')),
        (address[])
      ),
      clEmergencyOracle: abi.decode(
        json.parseRaw(string.concat(cccKey, 'clEmergencyOracle')),
        (address)
      ),
      confirmations: abi.decode(json.parseRaw(string.concat(cccKey, 'confirmations')), (uint8)),
      ethFunds: abi.decode(json.parseRaw(string.concat(cccKey, 'ethFunds')), (uint256)),
      owner: abi.decode(json.parseRaw(string.concat(cccKey, 'owner')), (address)),
      guardian: abi.decode(json.parseRaw(string.concat(cccKey, 'guardian')), (address)),
      salt: abi.decode(json.parseRaw(string.concat(cccKey, 'salt')), (string))
    });
    return ccc;
  }

  function _decodeConnections(
    string memory firstLvlKey,
    string memory connectionType,
    string memory json
  ) internal view returns (Connections memory) {
    string memory connectionTypeKey = string.concat(connectionType, '.');
    string memory connectionsKey = string.concat(firstLvlKey, connectionTypeKey);
    Connections memory connections;

    // get connected chains
    string memory chainIdsKey = string.concat(connectionsKey, 'chainIds');
    try this.decodeUint256Array(chainIdsKey, json) returns (uint256[] memory chainIds) {
      connections.chainIds = chainIds;
      // get adapters used by connected chain
      for (uint256 i = 0; i < chainIds.length; i++) {
        string memory networkName = _getChainNameById(chainIds[i]);
        string memory networkNamekey = string.concat(connectionsKey, networkName);
        uint256[] memory connectedAdapters;
        try this.decodeUint256Array(networkNamekey, json) returns (
          uint256[] memory connectionAdapters
        ) {
          connectedAdapters = connectionAdapters;
        } catch (bytes memory) {}
        if (networkName.eq('ethereum')) {
          connections.ethereum = connectedAdapters;
        } else if (networkName.eq('polygon')) {
          connections.polygon = connectedAdapters;
        } else if (networkName.eq('avalanche')) {
          connections.avalanche = connectedAdapters;
        } else if (networkName.eq('arbitrum')) {
          connections.arbitrum = connectedAdapters;
        } else if (networkName.eq('optimism')) {
          connections.optimism = connectedAdapters;
        } else if (networkName.eq('metis')) {
          connections.metis = connectedAdapters;
        } else if (networkName.eq('binance')) {
          connections.binance = connectedAdapters;
        } else if (networkName.eq('base')) {
          connections.base = connectedAdapters;
        } else if (networkName.eq('gnosis')) {
          connections.gnosis = connectedAdapters;
        } else if (networkName.eq('scroll')) {
          connections.scroll = connectedAdapters;
        } else if (networkName.eq('polygon_zkevm')) {
          connections.scroll = connectedAdapters;
        } else {
          // TODO: add test chains
          revert('Unrecognized network name');
        }
      }
    } catch (bytes memory) {}

    return connections;
  }

  function _decodeConfig(
    string memory deploymentJsonPath,
    Vm vm
  ) internal view returns (ChainDeploymentInfo[] memory) {
    string memory json = vm.readFile(string(abi.encodePacked(deploymentJsonPath)));

    uint256[] memory deploymentNetworks = abi.decode(json.parseRaw('.chains'), (uint256[]));
    ChainDeploymentInfo[] memory deploymentConfigs = new ChainDeploymentInfo[](
      deploymentNetworks.length
    );

    for (uint256 i = 0; i < deploymentNetworks.length; i++) {
      string memory networkKey = string.concat('.', Strings.toString(deploymentNetworks[i]));
      // first level of the config object
      string memory networkKey1rstLvl = string.concat(networkKey, '.');
      deploymentConfigs[i].chainId = abi.decode(
        json.parseRaw(string.concat(networkKey1rstLvl, 'chainId')),
        (uint256)
      );

      deploymentConfigs[i].adapters = _decodeAdapters(networkKey1rstLvl, json);

      // decode cross chain controller
      CCC memory ccc;
      try this.decodeCCC(networkKey1rstLvl, json) returns (CCC memory decodedCCC) {
        ccc = decodedCCC;
      } catch (bytes memory) {}

      deploymentConfigs[i].ccc = ccc;

      // decode forwarding connections
      Connections memory forwarderConnections = _decodeConnections(
        networkKey1rstLvl,
        'forwarderConnections',
        json
      );
      deploymentConfigs[i].forwarderConnections = forwarderConnections;

      Connections memory receiverConnections = _decodeConnections(
        networkKey1rstLvl,
        'receiverConnections',
        json
      );
      deploymentConfigs[i].receiverConnections = receiverConnections;

      console.log('remote network', deploymentConfigs[i].receiverConnections.ethereum.length);
    }

    return deploymentConfigs;
  }

  //  function _getDeploymentConfigurationByChainId(
  //    uint256 chainId,
  //    string memory deploymentJsonPath,
  //    Vm vm
  //  ) internal returns (ChainDeploymentInfo memory) {
  //    ChainDeploymentInfo[] memory deploymentConfigs = _decodeConfig(deploymentJsonPath, vm);
  //    ChainDeploymentInfo memory deploymentConfig;
  //
  //    for (uint256 i = 0; i < deploymentConfigs.length; i++) {
  //      require(deploymentConfigs[i].chainId > 0, 'WRONG_DEPLOYMENT_CONFIGURATION');
  //      if (deploymentConfigs[i].chainId == chainId) {
  //        deploymentConfig = deploymentConfigs[i];
  //        break;
  //      }
  //    }
  //
  //    return deploymentConfig;
  //  }
}
