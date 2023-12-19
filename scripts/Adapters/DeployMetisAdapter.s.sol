// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MetisAdapter, IBaseAdapter} from '../../src/contracts/adapters/metis/MetisAdapter.sol';
import './BaseAdapterScript.sol';
import {MetisAdapterTestnet} from '../contract_extensions/MetisAdapter.sol';

abstract contract BaseMetisAdapter is BaseAdapterScript {
  function OVM() public view virtual returns (address);

  function isTestnet() public view virtual returns (bool) {
    return false;
  }

  function GET_BASE_GAS_LIMIT() public view virtual override returns (uint256) {
    return 150_000;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestnet()) {
      addresses.metisAdapter = address(
        new MetisAdapterTestnet(
          addresses.crossChainController,
          OVM(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      addresses.metisAdapter = address(
        new MetisAdapter(
          addresses.crossChainController,
          OVM(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
  }
}

contract Ethereum is BaseMetisAdapter {
  function OVM() public pure override returns (address) {
    return 0x081D1101855bD523bA69A9794e0217F0DB6323ff;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Metis is BaseMetisAdapter {
  function OVM() public pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

contract Ethereum_testnet is BaseMetisAdapter {
  function OVM() public pure override returns (address) {
    return 0x914Aed79Cd083B5043C75A90616CC2A0477bf86c;
  }

  function isTestnet() public pure override returns (bool) {
    return true;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Metis_testnet is BaseMetisAdapter {
  function OVM() public pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function isTestnet() public pure override returns (bool) {
    return true;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return remoteNetworks;
  }
}
