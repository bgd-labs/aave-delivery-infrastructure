// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/StdJson.sol';
import 'forge-std/Vm.sol';
import './PathHelpers.sol';

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
  uint8[] ethereum;
  uint8[] avalanche;
  uint8[] polygon;
  uint8[] arbitrum;
  uint8[] optimism;
  uint8[] polygon_zkevm;
  uint8[] binance;
  uint8[] base;
  uint8[] metis;
  uint8[] gnosis;
  uint8[] scroll;
  uint8[] ethereum_sepolia;
  uint8[] polygon_mumbai;
  uint8[] avalanche_fuji;
}

struct Confirmations {
  uint256[] chainIds;
  uint8 ethereum;
  uint8 avalanche;
  uint8 polygon;
  uint8 arbitrum;
  uint8 optimism;
  uint8 polygon_zkevm;
  uint8 binance;
  uint8 base;
  uint8 metis;
  uint8 gnosis;
  uint8 scroll;
  uint8 ethereum_sepolia;
  uint8 polygon_mumbai;
  uint8 avalanche_fuji;
}

struct AdaptersDeploymentInfo {
  CCIPAdapterInfo ccipAdapter;
  ScrollAdapterInfo scrollAdapter;
}

struct ProxyInfo {
  address deployedAddress;
  address owner;
  string salt;
}

struct ProxyContracts {
  ProxyInfo create3;
  ProxyInfo proxyAdmin;
  ProxyInfo transparentProxyFactory;
}

struct CCC {
  address[] approvedSenders;
  address clEmergencyOracle;
  Confirmations confirmations;
  uint256 ethFunds;
  address guardian;
  bool onlyImpl;
  address owner;
  string salt;
  address[] sendersToRemove;
}

struct EmergencyRegistryInfo {
  address owner;
}

struct ChainDeploymentInfo {
  AdaptersDeploymentInfo adapters;
  CCC ccc;
  uint256 chainId;
  EmergencyRegistryInfo emergencyRegistry;
  Connections forwarderConnections;
  ProxyContracts proxies;
  Connections receiverConnections;
  string revision;
}

enum Adapters {
  Null_Adapter,
  Same_Chain,
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

contract DeployJsonDecodeHelpers {
  using stdJson for string;
  using StringUtils for string;

  function decodeBool(string memory path, string memory json) external pure returns (bool) {
    return abi.decode(json.parseRaw(path), (bool));
  }

  function decodeAddress(string memory path, string memory json) external pure returns (address) {
    return abi.decode(json.parseRaw(path), (address));
  }

  function decodeUint8(string memory path, string memory json) external pure returns (uint8) {
    return abi.decode(json.parseRaw(path), (uint8));
  }

  function decodeUint256(string memory path, string memory json) external pure returns (uint256) {
    return abi.decode(json.parseRaw(path), (uint256));
  }

  function decodeString(
    string memory path,
    string memory json
  ) external pure returns (string memory) {
    return abi.decode(json.parseRaw(path), (string));
  }

  function decodeUint8Array(
    string memory path,
    string memory json
  ) external pure returns (uint8[] memory) {
    return abi.decode(json.parseRaw(path), (uint8[]));
  }

  function decodeUint256Array(
    string memory path,
    string memory json
  ) external pure returns (uint256[] memory) {
    return abi.decode(json.parseRaw(path), (uint256[]));
  }

  function decodeAddressArray(
    string memory path,
    string memory json
  ) external pure returns (address[] memory) {
    return abi.decode(json.parseRaw(path), (address[]));
  }

  function tryDecodeBool(string memory key, string memory json) internal view returns (bool) {
    bool boolDecoded;
    try this.decodeBool(key, json) returns (bool decodedBool) {
      boolDecoded = decodedBool;
    } catch (bytes memory) {}

    return boolDecoded;
  }

  function tryDecodeAddress(string memory key, string memory json) internal view returns (address) {
    address addressDecoded;
    try this.decodeAddress(key, json) returns (address decodedAddress) {
      addressDecoded = decodedAddress;
    } catch (bytes memory) {}

    return addressDecoded;
  }

  function tryDecodeAddresses(
    string memory key,
    string memory json
  ) internal view returns (address[] memory) {
    address[] memory addresses;
    try this.decodeAddressArray(key, json) returns (address[] memory decodedAddresses) {
      addresses = decodedAddresses;
    } catch (bytes memory) {}

    return addresses;
  }

  function tryDecodeUint256(string memory key, string memory json) internal view returns (uint256) {
    uint256 number;
    try this.decodeUint256(key, json) returns (uint256 decodedNumber) {
      number = decodedNumber;
    } catch (bytes memory) {}

    return number;
  }

  function tryDecodeUint256Array(
    string memory key,
    string memory json
  ) internal view returns (uint256[] memory) {
    uint256[] memory numbers;
    try this.decodeUint256Array(key, json) returns (uint256[] memory decodedNumbers) {
      numbers = decodedNumbers;
    } catch (bytes memory) {}

    return numbers;
  }

  function tryDecodeString(
    string memory addressKey,
    string memory json
  ) internal view returns (string memory) {
    string memory stringInfo;
    try this.decodeString(addressKey, json) returns (string memory decodedString) {
      stringInfo = decodedString;
    } catch (bytes memory) {}

    return stringInfo;
  }

  function _getConfirmations(
    uint256 chainId,
    Confirmations memory confirmations
  ) internal pure returns (uint8) {
    if (chainId == ChainIds.ETHEREUM) {
      return confirmations.ethereum;
    } else if (chainId == ChainIds.POLYGON) {
      return confirmations.polygon;
    } else if (chainId == ChainIds.AVALANCHE) {
      return confirmations.avalanche;
    } else if (chainId == ChainIds.ARBITRUM) {
      return confirmations.arbitrum;
    } else if (chainId == ChainIds.OPTIMISM) {
      return confirmations.optimism;
    } else if (chainId == ChainIds.METIS) {
      return confirmations.metis;
    } else if (chainId == ChainIds.BNB) {
      return confirmations.binance;
    } else if (chainId == ChainIds.BASE) {
      return confirmations.base;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return confirmations.polygon_zkevm;
    } else if (chainId == ChainIds.GNOSIS) {
      return confirmations.gnosis;
    } else if (chainId == ChainIds.SCROLL) {
      return confirmations.scroll;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return confirmations.ethereum_sepolia;
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return confirmations.polygon_mumbai;
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return confirmations.avalanche_fuji;
    } else {
      return uint8(0);
    }
  }

  function _getAdapterIds(
    uint256 chainId,
    Connections memory connections
  ) internal pure returns (uint8[] memory) {
    if (chainId == ChainIds.ETHEREUM) {
      return connections.ethereum;
    } else if (chainId == ChainIds.POLYGON) {
      return connections.polygon;
    } else if (chainId == ChainIds.AVALANCHE) {
      return connections.avalanche;
    } else if (chainId == ChainIds.ARBITRUM) {
      return connections.arbitrum;
    } else if (chainId == ChainIds.OPTIMISM) {
      return connections.optimism;
    } else if (chainId == ChainIds.METIS) {
      return connections.metis;
    } else if (chainId == ChainIds.BNB) {
      return connections.binance;
    } else if (chainId == ChainIds.BASE) {
      return connections.base;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return connections.polygon_zkevm;
    } else if (chainId == ChainIds.GNOSIS) {
      return connections.gnosis;
    } else if (chainId == ChainIds.SCROLL) {
      return connections.scroll;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return connections.ethereum_sepolia;
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return connections.polygon_mumbai;
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return connections.avalanche_fuji;
    } else {
      return new uint8[](0);
    }
  }

  function _getAdapterById(
    Addresses memory addresses,
    Adapters adapter
  ) internal pure returns (address) {
    if (adapter == Adapters.CCIP) {
      return addresses.ccipAdapter;
    } else if (adapter == Adapters.Scroll_Native) {
      return addresses.scrollAdapter;
    } else if (adapter == Adapters.Arbitrum_Native) {
      return addresses.arbAdapter;
    } else if (adapter == Adapters.Optimism_Native) {
      return addresses.opAdapter;
    } else if (adapter == Adapters.Polygon_Native) {
      return addresses.polAdapter;
    } else if (adapter == Adapters.Gnosis_Native) {
      return addresses.gnosisAdapter;
    } else if (adapter == Adapters.Metis_Native) {
      return addresses.metisAdapter;
    } else if (adapter == Adapters.LayerZero) {
      return addresses.lzAdapter;
    } else if (adapter == Adapters.Hyperlane) {
      return addresses.hlAdapter;
    } else if (adapter == Adapters.Polygon_ZkEvm_Native) {
      return addresses.zkevmAdapter;
    } else if (adapter == Adapters.Base_Native) {
      return addresses.baseAdapter;
    } else if (adapter == Adapters.Same_Chain) {
      return addresses.sameChainAdapter;
    } else {
      return address(0);
    }
  }

  function getAdapter(
    Adapters adapterId,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses
  ) internal pure returns (address) {
    // TODO: do we need more checks here?
    if (_getAdapterById(revisionAddresses, adapterId) != address(0)) {
      return _getAdapterById(revisionAddresses, adapterId);
    } else if (_getAdapterById(currentAddresses, adapterId) != address(0)) {
      return _getAdapterById(currentAddresses, adapterId);
    } else {
      return address(0);
    }
  }

  function decodeScrollAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (ScrollAdapterInfo memory) {
    string memory scrollAdapterKey = string.concat(adapterKey, 'scrollAdapter.');

    ScrollAdapterInfo memory scrollAdapter = ScrollAdapterInfo({
      inbox: tryDecodeAddress(string.concat(scrollAdapterKey, 'inbox'), json),
      remoteNetworks: tryDecodeUint256Array(string.concat(scrollAdapterKey, 'remoteNetworks'), json)
    });

    return scrollAdapter;
  }

  function decodeCCIPAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (CCIPAdapterInfo memory) {
    string memory ccipAdapterKey = string.concat(adapterKey, 'ccipAdapter.');

    return
      CCIPAdapterInfo({
        ccipRouter: tryDecodeAddress(string.concat(ccipAdapterKey, 'ccipRouter'), json),
        linkToken: tryDecodeAddress(string.concat(ccipAdapterKey, 'linkToken'), json),
        remoteNetworks: tryDecodeUint256Array(string.concat(ccipAdapterKey, 'remoteNetworks'), json)
      });
  }

  function decodeAdapters(
    string memory firstLvlKey,
    string memory json
  ) internal view returns (AdaptersDeploymentInfo memory) {
    string memory adaptersKey = string.concat(firstLvlKey, 'adapters.');

    AdaptersDeploymentInfo memory adapters = AdaptersDeploymentInfo({
      scrollAdapter: decodeScrollAdapter(adaptersKey, json),
      ccipAdapter: decodeCCIPAdapter(adaptersKey, json)
    });

    return adapters;
  }

  function decodeEmergencyRegistry(
    string memory firstLvlKey,
    string memory json
  ) internal view returns (EmergencyRegistryInfo memory) {
    string memory erKey = string.concat(firstLvlKey, 'emergencyRegistry.');

    EmergencyRegistryInfo memory emergencyRegistry = EmergencyRegistryInfo({
      owner: tryDecodeAddress(string.concat(erKey, 'owner'), json)
    });

    return emergencyRegistry;
  }

  function decodeCCC(
    string memory firstLvlKey,
    string memory json
  ) external view returns (CCC memory) {
    string memory cccKey = string.concat(firstLvlKey, 'ccc.');

    uint8 confirmations;
    try this.decodeUint8(string.concat(cccKey, 'confirmations'), json) returns (
      uint8 decodedConfirmations
    ) {
      confirmations = decodedConfirmations;
    } catch (bytes memory) {}

    CCC memory ccc = CCC({
      approvedSenders: tryDecodeAddresses(string.concat(cccKey, 'approvedSenders'), json),
      sendersToRemove: tryDecodeAddresses(string.concat(cccKey, 'sendersToRemove'), json),
      clEmergencyOracle: tryDecodeAddress(string.concat(cccKey, 'clEmergencyOracle'), json),
      confirmations: decodeConfirmations(cccKey, json),
      ethFunds: tryDecodeUint256(string.concat(cccKey, 'ethFunds'), json),
      salt: tryDecodeString(string.concat(cccKey, 'salt'), json),
      onlyImpl: tryDecodeBool(string.concat(cccKey, 'onlyImpl'), json),
      owner: tryDecodeAddress(string.concat(cccKey, 'owner'), json), // TODO: should we put this also on deployed addresses
      guardian: tryDecodeAddress(string.concat(cccKey, 'guardian'), json) // TODO: should we put this also on deployed addresses
    });
    return ccc;
  }

  function decodeConfirmations(
    string memory firstLvlKey,
    string memory json
  ) internal view returns (Confirmations memory) {
    string memory confirmationsKey = string.concat(firstLvlKey, 'confirmations.');
    Confirmations memory confirmationsByNetwork;

    // get connected chains
    string memory chainIdsKey = string.concat(confirmationsKey, 'chainIds');
    try this.decodeUint256Array(chainIdsKey, json) returns (uint256[] memory chainIds) {
      confirmationsByNetwork.chainIds = chainIds;
      // get adapters used by connected chain
      for (uint256 i = 0; i < chainIds.length; i++) {
        string memory networkName = PathHelpers.getChainNameById(chainIds[i]);
        string memory networkNameKey = string.concat(confirmationsKey, networkName);
        uint8 confirmations;
        try this.decodeUint8(networkNameKey, json) returns (uint8 decodedConfirmations) {
          confirmations = decodedConfirmations;
        } catch (bytes memory) {}
        if (networkName.eq('ethereum')) {
          confirmationsByNetwork.ethereum = confirmations;
        } else if (networkName.eq('polygon')) {
          confirmationsByNetwork.polygon = confirmations;
        } else if (networkName.eq('avalanche')) {
          confirmationsByNetwork.avalanche = confirmations;
        } else if (networkName.eq('arbitrum')) {
          confirmationsByNetwork.arbitrum = confirmations;
        } else if (networkName.eq('optimism')) {
          confirmationsByNetwork.optimism = confirmations;
        } else if (networkName.eq('metis')) {
          confirmationsByNetwork.metis = confirmations;
        } else if (networkName.eq('binance')) {
          confirmationsByNetwork.binance = confirmations;
        } else if (networkName.eq('base')) {
          confirmationsByNetwork.base = confirmations;
        } else if (networkName.eq('gnosis')) {
          confirmationsByNetwork.gnosis = confirmations;
        } else if (networkName.eq('scroll')) {
          confirmationsByNetwork.scroll = confirmations;
        } else if (networkName.eq('polygon_zkevm')) {
          confirmationsByNetwork.polygon_zkevm = confirmations;
        }
        // TODO: add test chains
        else if (networkName.eq('ethereum_sepolia')) {
          confirmationsByNetwork.ethereum_sepolia = confirmations;
        } else if (networkName.eq('polygon_mumbai')) {
          confirmationsByNetwork.polygon_mumbai = confirmations;
        } else if (networkName.eq('avalanche_fuji')) {
          confirmationsByNetwork.avalanche_fuji = confirmations;
        } else {
          revert('Unrecognized network name');
        }
      }
    } catch (bytes memory) {}

    return confirmationsByNetwork;
  }

  // TODO: quite similar to decodeConfirmations method, but could not find a way to deduplicate
  function decodeConnections(
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
        string memory networkName = PathHelpers.getChainNameById(chainIds[i]);
        string memory networkNamekey = string.concat(connectionsKey, networkName);
        uint8[] memory connectedAdapters;
        try this.decodeUint8Array(networkNamekey, json) returns (
          uint8[] memory connectionAdapters
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
          connections.polygon_zkevm = connectedAdapters;
        }
        // TODO: add test chains
        else if (networkName.eq('ethereum_sepolia')) {
          connections.ethereum_sepolia = connectedAdapters;
        } else if (networkName.eq('polygon_mumbai')) {
          connections.polygon_mumbai = connectedAdapters;
        } else if (networkName.eq('avalanche_fuji')) {
          connections.avalanche_fuji = connectedAdapters;
        } else {
          revert('Unrecognized network name');
        }
      }
    } catch (bytes memory) {}

    return connections;
  }

  function decodeProxyByType(
    string memory proxiesKey,
    string memory proxyType,
    string memory json
  ) internal view returns (ProxyInfo memory) {
    string memory proxyPath = string.concat(proxiesKey, proxyType);
    string memory proxyKey = string.concat(proxyPath, '.');

    string memory salt;
    try this.decodeString(string.concat(proxyKey, 'salt'), json) returns (
      string memory decodedSalt
    ) {
      salt = decodedSalt;
    } catch (bytes memory) {}

    address deployedAddress;
    try this.decodeAddress(string.concat(proxyKey, 'deployedAddress'), json) returns (
      address decodedDeployedAddress
    ) {
      deployedAddress = decodedDeployedAddress;
    } catch (bytes memory) {}

    address owner;
    try this.decodeAddress(string.concat(proxyKey, 'owner'), json) returns (address decodedOwner) {
      owner = decodedOwner;
    } catch (bytes memory) {}

    return ProxyInfo({deployedAddress: deployedAddress, salt: salt, owner: owner});
  }

  function decodeProxies(
    string memory networkKey1rstLvl,
    string memory json
  ) internal view returns (ProxyContracts memory) {
    string memory proxiesKey = string.concat(networkKey1rstLvl, 'proxies.');

    ProxyContracts memory proxies = ProxyContracts({
      proxyAdmin: decodeProxyByType(proxiesKey, 'proxyAdmin', json),
      transparentProxyFactory: decodeProxyByType(proxiesKey, 'transparentProxyFactory', json),
      create3: decodeProxyByType(proxiesKey, 'create3', json)
    });

    return proxies;
  }

  function decodeChainId(
    string memory networkKey1rstLvl,
    string memory json
  ) internal pure returns (uint256) {
    return abi.decode(json.parseRaw(string.concat(networkKey1rstLvl, 'chainId')), (uint256));
  }

  function decodeChains(string memory json) internal pure returns (string[] memory) {
    return abi.decode(json.parseRaw('.chains'), (string[]));
  }
}

struct Addresses {
  address arbAdapter;
  address baseAdapter;
  address ccipAdapter;
  uint256 chainId;
  address clEmergencyOracle;
  address create3Factory;
  address crossChainController;
  address crossChainControllerImpl;
  address emergencyRegistry;
  address gnosisAdapter;
  address guardian;
  address hlAdapter;
  address lzAdapter;
  address metisAdapter;
  address mockDestination;
  address opAdapter;
  address owner;
  address polAdapter;
  address proxyAdmin;
  address proxyFactory;
  address sameChainAdapter;
  address scrollAdapter;
  uint256 version;
  address zkevmAdapter;
}

library AddressesHelpers {
  using stdJson for string;

  function decodeAddressesJson(string memory json) internal pure returns (Addresses memory) {
    Addresses memory addresses = Addresses({
      proxyAdmin: abi.decode(json.parseRaw('.proxyAdmin'), (address)),
      proxyFactory: abi.decode(json.parseRaw('.proxyFactory'), (address)),
      owner: abi.decode(json.parseRaw('.owner'), (address)),
      guardian: abi.decode(json.parseRaw('.guardian'), (address)),
      clEmergencyOracle: abi.decode(json.parseRaw('.clEmergencyOracle'), (address)),
      create3Factory: abi.decode(json.parseRaw('.create3Factory'), (address)),
      crossChainController: abi.decode(json.parseRaw('.crossChainController'), (address)),
      crossChainControllerImpl: abi.decode(json.parseRaw('.crossChainControllerImpl'), (address)),
      ccipAdapter: abi.decode(json.parseRaw('.ccipAdapter'), (address)),
      sameChainAdapter: abi.decode(json.parseRaw('.sameChainAdapter'), (address)),
      chainId: abi.decode(json.parseRaw('.chainId'), (uint256)),
      emergencyRegistry: abi.decode(json.parseRaw('.emergencyRegistry'), (address)),
      lzAdapter: abi.decode(json.parseRaw('.lzAdapter'), (address)),
      hlAdapter: abi.decode(json.parseRaw('.hlAdapter'), (address)),
      opAdapter: abi.decode(json.parseRaw('.opAdapter'), (address)),
      arbAdapter: abi.decode(json.parseRaw('.arbAdapter'), (address)),
      metisAdapter: abi.decode(json.parseRaw('.metisAdapter'), (address)),
      polAdapter: abi.decode(json.parseRaw('.polAdapter'), (address)),
      mockDestination: abi.decode(json.parseRaw('.mockDestination'), (address)),
      baseAdapter: abi.decode(json.parseRaw('.baseAdapter'), (address)),
      zkevmAdapter: abi.decode(json.parseRaw('.zkevmAdapter'), (address)),
      gnosisAdapter: abi.decode(json.parseRaw('.gnosisAdapter'), (address)),
      scrollAdapter: abi.decode(json.parseRaw('.scrollAdapter'), (address)),
      version: abi.decode(json.parseRaw('.version'), (uint256))
    });

    return addresses;
  }

  function saveAddresses(string memory path, Addresses memory addresses, Vm vm) internal {
    string memory json = 'addresses';
    json.serialize('arbAdapter', addresses.arbAdapter);
    json.serialize('baseAdapter', addresses.baseAdapter);
    json.serialize('ccipAdapter', addresses.ccipAdapter);
    json.serialize('chainId', addresses.chainId);
    json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
    json.serialize('create3Factory', addresses.create3Factory);
    json.serialize('crossChainController', addresses.crossChainController);
    json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
    json.serialize('emergencyRegistry', addresses.emergencyRegistry);
    json.serialize('gnosisAdapter', addresses.gnosisAdapter);
    json.serialize('guardian', addresses.guardian);
    json.serialize('hlAdapter', addresses.hlAdapter);
    json.serialize('lzAdapter', addresses.lzAdapter);
    json.serialize('metisAdapter', addresses.metisAdapter);
    json.serialize('mockDestination', addresses.mockDestination);
    json.serialize('opAdapter', addresses.opAdapter);
    json.serialize('owner', addresses.owner);
    json.serialize('polAdapter', addresses.polAdapter);
    json.serialize('proxyAdmin', addresses.proxyAdmin);
    json.serialize('proxyFactory', addresses.proxyFactory);
    json.serialize('sameChainAdapter', addresses.sameChainAdapter);
    json.serialize('scrollAdapter', addresses.scrollAdapter);
    json.serialize('version', addresses.version);
    json = json.serialize('zkevmAdapter', addresses.zkevmAdapter);
    vm.writeJson(json, path);
  }
}
