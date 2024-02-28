// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WormholeAdapter, IWormholeAdapter, IBaseAdapter} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import './BaseAdapterScript.sol';
import {WormholeAdapterTestnet} from '../contract_extensions/WormholeAdapter.sol';

abstract contract BaseWormholeAdapter is BaseAdapterScript {
  function WORMHOLE_RELAYER() public view virtual returns (address);

  function isTestNet() public view virtual returns (bool) {
    return false;
  }

  /// @dev for now we will need to deploy one adapter for every path (one remote network) because of the refunding on
  /// destination ccc
  function DESTINATION_CCC() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestNet()) {
      addresses.wormholeAdapter = address(
        new WormholeAdapterTestnet(
          addresses.crossChainController,
          WORMHOLE_RELAYER(),
          DESTINATION_CCC(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      addresses.wormholeAdapter = address(
        new WormholeAdapter(
          addresses.crossChainController,
          WORMHOLE_RELAYER(),
          DESTINATION_CCC(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
  }
}

contract Ethereum is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x27428DD2d3DD32A4D7f7C497eAaa23130d894911;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function DESTINATION_CCC() public view override returns (address) {
    DeployerHelpers.Addresses memory destinationAddresses = _getAddresses(ChainIds.CELO);
    return destinationAddresses.crossChainController;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Ethereum_testnet is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x7B1bD7a6b4E61c2a123AC6BC2cbfC614437D0470;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function DESTINATION_CCC() public view override returns (address) {
    DeployerHelpers.Addresses memory destinationAddresses = _getAddresses(
      TestNetChainIds.CELO_ALFAJORES
    );
    return destinationAddresses.crossChainController;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Celo is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x27428DD2d3DD32A4D7f7C497eAaa23130d894911;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function DESTINATION_CCC() public pure override returns (address) {
    return address(0);
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

contract Celo_testnet is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x306B68267Deb7c5DfCDa3619E22E9Ca39C374f84;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }

  function DESTINATION_CCC() public pure override returns (address) {
    return address(0);
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }
}
