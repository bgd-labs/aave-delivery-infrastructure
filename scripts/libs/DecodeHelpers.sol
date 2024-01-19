// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/StdJson.sol';
import './PathHelpers.sol';

library BaseDecodeHelpers {
  using stdJson for string;

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
}

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
  address guardian;
  address owner;
  string salt;
}

struct ChainDeploymentInfo {
  AdaptersDeploymentInfo adapters;
  CCC ccc;
  uint256 chainId;
  Connections forwarderConnections;
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

library DeployJsonDecodeHelpers {
  using stdJson for string;
  using StringUtils for string;

  function decodeScrollAdapter(
    string memory adapterKey,
    string memory json
  ) internal view returns (ScrollAdapterInfo memory) {
    string memory scrollAdapterKey = string.concat(adapterKey, 'scrollAdapter.');
    address inbox;

    try BaseDecodeHelpers.decodeAddress(string.concat(scrollAdapterKey, 'inbox'), json) returns (
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
  ) internal pure returns (CCIPAdapterInfo memory) {
    string memory ccipAdapterKey = string.concat(adapterKey, 'ccipAdapter.');

    address ccipRouter;
    try BaseDecodeHelpers.decodeAddress(string.concat(ccipAdapterKey, 'ccipRouter'), json) returns (
      address decodedCCIPRouter
    ) {
      ccipRouter = decodedCCIPRouter;
    } catch (bytes memory) {}

    address linkToken;
    try BaseDecodeHelpers.decodeAddress(string.concat(ccipAdapterKey, 'linkToken'), json) returns (
      address decodedLinkToken
    ) {
      linkToken = decodedLinkToken;
    } catch (bytes memory) {}

    uint256[] memory remoteNetworks;
    try
      BaseDecodeHelpers.decodeUint256Array(string.concat(ccipAdapterKey, 'remoteNetworks'), json)
    returns (uint256[] memory decodedRemoteNetworks) {
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
      owner: abi.decode(json.parseRaw(string.concat(cccKey, 'owner')), (address)),
      guardian: abi.decode(json.parseRaw(string.concat(cccKey, 'guardian')), (address)),
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
    try BaseDecodeHelpers.decodeUint256Array(chainIdsKey, json) returns (
      uint256[] memory chainIds
    ) {
      connections.chainIds = chainIds;
      // get adapters used by connected chain
      for (uint256 i = 0; i < chainIds.length; i++) {
        string memory networkName = PathHelpers.getChainNameById(chainIds[i]);
        string memory networkNamekey = string.concat(connectionsKey, networkName);
        uint256[] memory connectedAdapters;
        try BaseDecodeHelpers.decodeUint256Array(networkNamekey, json) returns (
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
    try BaseDecodeHelpers.decodeString(string.concat(proxyKey, 'salt'), json) returns (
      string memory decodedSalt
    ) {
      salt = decodedSalt;
    } catch (bytes memory) {}

    address deployedAddress;
    try BaseDecodeHelpers.decodeAddress(string.concat(proxyKey, 'deployedAddress'), json) returns (
      address decodedDeployedAddress
    ) {
      deployedAddress = decodedDeployedAddress;
    } catch (bytes memory) {}

    return ProxyInfo({deployedAddress: deployedAddress, salt: salt});
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
  ) internal view returns (uint256) {
    return abi.decode(json.parseRaw(string.concat(networkKey1rstLvl, 'chainId')), (uint256));
  }

  function decodeChains(string memory json) internal view returns (uint256[] memory) {
    return abi.decode(json.parseRaw('.chains'), (uint256[]));
  }
}
