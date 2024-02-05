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

  function getDestinationCCC() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestNet()) {
      addresses.ccipAdapter = address(
        new WormholeAdapterTestnet(
          addresses.crossChainController,
          WORMHOLE_RELAYER(),
          getDestinationCCC,
          trustedRemotes
        )
      );
    } else {
      addresses.wormholeAdapter = address(
        new WormholeAdapter(
          addresses.crossChainController,
          WORMHOLE_RELAYER(),
          getDestinationCCC,
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

  function getDestinationCCC() public view virtual returns (address) {}

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.CELO;

    return remoteNetworks;
  }
}

contract Ethereum_testnet is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x7B1bD7a6b4E61c2a123AC6BC2cbfC614437D0470;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.CELO_ALFAJORES;

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

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Celo_testnet is BaseWormholeAdapter {
  function WORMHOLE_RELAYER() public pure override returns (address) {
    return 0x306B68267Deb7c5DfCDa3619E22E9Ca39C374f84;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO_ALFAJORES;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}
