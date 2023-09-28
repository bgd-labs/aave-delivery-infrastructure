// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {OpAdapter, IOpAdapter, IBaseAdapter} from '../../src/contracts/adapters/optimism/OpAdapter.sol';
import './BaseAdapterScript.sol';
import {OptimismAdapterTestnet} from '../contract_extensions/OptimismAdapter.sol';

abstract contract BaseOpAdapter is BaseAdapterScript {
  function OVM() public view virtual returns (address);

  function isTestnet() public view virtual returns (bool) {
    return false;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestnet()) {
      addresses.opAdapter = address(
        new OptimismAdapterTestnet(addresses.crossChainController, OVM(), trustedRemotes)
      );
    } else {
      addresses.opAdapter = address(
        new OpAdapter(addresses.crossChainController, OVM(), trustedRemotes)
      );
    }
  }
}

contract Ethereum is BaseOpAdapter {
  function OVM() public pure override returns (address) {
    return 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);

    return remoteNetworks;
  }
}

contract Optimism is BaseOpAdapter {
  function OVM() public pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

contract Ethereum_testnet is BaseOpAdapter {
  function OVM() public pure override returns (address) {
    return 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;
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

contract Optimism_testnet is BaseOpAdapter {
  function OVM() public pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function isTestnet() public pure override returns (bool) {
    return true;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return remoteNetworks;
  }
}
