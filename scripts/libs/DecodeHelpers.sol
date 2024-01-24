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
  address owner;
}

struct ProxyContracts {
  ProxyInfo create3;
  ProxyInfo proxyAdmin;
  ProxyInfo transparentProxyFactory;
}

struct CCC {
  address[] approvedSenders;
  address clEmergencyOracle;
  uint8 confirmations;
  uint256 ethFunds;
  string salt;
}

struct ChainDeploymentInfo {
  AdaptersDeploymentInfo adapters;
  CCC ccc;
  uint256 chainId;
  Connections forwarderConnections;
  address guardian;
  ProxyContracts proxies;
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

contract DeployJsonDecodeHelpers {
  using stdJson for string;
  using StringUtils for string;

  function decodeAddress(string memory path, string memory json) external pure returns (address) {
    return abi.decode(json.parseRaw(path), (address));
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

  function decodeUint256Array(
    string memory path,
    string memory json
  ) external pure returns (uint256[] memory) {
    return abi.decode(json.parseRaw(path), (uint256[]));
  }

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

  function decodeScrollAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (ScrollAdapterInfo memory) {
    string memory scrollAdapterKey = string.concat(adapterKey, 'scrollAdapter.');
    address inbox;

    try this.decodeAddress(string.concat(scrollAdapterKey, 'inbox'), json) returns (
      address decodedInbox
    ) {
      inbox = decodedInbox;
    } catch (bytes memory) {}

    uint256[] memory remoteNetworks;
    try this.decodeUint256Array(string.concat(scrollAdapterKey, 'remoteNetworks'), json) returns (
      uint256[] memory decodedRemoteNetworks
    ) {
      remoteNetworks = decodedRemoteNetworks;
    } catch (bytes memory) {}

    ScrollAdapterInfo memory scrollAdapter = ScrollAdapterInfo({
      inbox: inbox,
      remoteNetworks: remoteNetworks
    });

    return scrollAdapter;
  }

  function decodeCCIPAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (CCIPAdapterInfo memory) {
    string memory ccipAdapterKey = string.concat(adapterKey, 'ccipAdapter.');

    address ccipRouter;
    try this.decodeAddress(string.concat(ccipAdapterKey, 'ccipRouter'), json) returns (
      address decodedCCIPRouter
    ) {
      ccipRouter = decodedCCIPRouter;
    } catch (bytes memory) {}

    address linkToken;
    try this.decodeAddress(string.concat(ccipAdapterKey, 'linkToken'), json) returns (
      address decodedLinkToken
    ) {
      linkToken = decodedLinkToken;
    } catch (bytes memory) {}

    uint256[] memory remoteNetworks;
    try this.decodeUint256Array(string.concat(ccipAdapterKey, 'remoteNetworks'), json) returns (
      uint256[] memory decodedRemoteNetworks
    ) {
      remoteNetworks = decodedRemoteNetworks;
    } catch (bytes memory) {}

    return
      CCIPAdapterInfo({
        ccipRouter: ccipRouter,
        linkToken: linkToken,
        remoteNetworks: remoteNetworks
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

  function tryDecodeAddress(
    string memory addressKey,
    string memory json
  ) internal view returns (address) {
    address addressDecoded;
    try this.decodeAddress(addressKey, json) returns (address decodedAddress) {
      addressDecoded = decodedAddress;
    } catch (bytes memory) {}

    return addressDecoded;
  }

  function decodeCCC(
    string memory firstLvlKey,
    string memory json
  ) external pure returns (CCC memory) {
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
      salt: abi.decode(json.parseRaw(string.concat(cccKey, 'salt')), (string))
    });
    return ccc;
  }

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

  function decodeChains(string memory json) internal pure returns (uint256[] memory) {
    return abi.decode(json.parseRaw('.chains'), (uint256[]));
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
