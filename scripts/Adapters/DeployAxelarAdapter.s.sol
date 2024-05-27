// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AxelarAdapter, IAxelarAdapter, IBaseAdapter} from '../../src/contracts/adapters/axelar/AxelarAdapter.sol';
import {AxelarAdapterTestnet} from '../contract_extensions/AxelarAdapter.sol';
import '../BaseScript.sol';
import './BaseAdapterScript.sol';

abstract contract BaseAxelarAdapter is BaseAdapterScript {
  function AXELAR_GATEWAY() public view virtual returns (address);

  function AXELAR_GAS_SERVICE() public view virtual returns (address);

  function isTestNet() public view virtual returns (bool);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    address axelarAdapter;
    if (isTestNet()) {
      axelarAdapter = address(
        new AxelarAdapterTestnet(
          AXELAR_GATEWAY(),
          AXELAR_GAS_SERVICE(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      axelarAdapter = address(
        new AxelarAdapter(
          AXELAR_GATEWAY(),
          AXELAR_GAS_SERVICE(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
    addresses.axelarAdapter = axelarAdapter;
  }
}

contract Ethereum is BaseAxelarAdapter {
  function AXELAR_GATEWAY() public pure override returns (address) {
    return 0x4F4495243837681061C4743b74B3eEdf548D56A5;
  }

  function AXELAR_GAS_SERVICE() public pure override returns (address) {
    return 0x2d5d7d31F671F86C782533cc367F14109a082712;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    return new uint256[](2);
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Ethereum_testnet is BaseAxelarAdapter {
  function AXELAR_GATEWAY() public pure override returns (address) {
    return 0xe432150cce91c13a887f7D836923d5597adD8E31;
  }

  function AXELAR_GAS_SERVICE() public pure override returns (address) {
    return 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    return new uint256[](0);
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Scroll_testnet is BaseAxelarAdapter {
  function AXELAR_GATEWAY() public pure override returns (address) {
    return 0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B;
  }

  function AXELAR_GAS_SERVICE() public pure override returns (address) {
    return 0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.SCROLL_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }
}
