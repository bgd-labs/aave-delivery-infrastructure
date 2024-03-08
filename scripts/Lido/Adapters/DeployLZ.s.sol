// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LayerZeroAdapter, ILayerZeroAdapter, IBaseAdapter} from '../../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {LayerZeroAdapterTestnet} from '../../contract_extensions/LayerZeroAdapter.sol';

import '../BaseScript.sol';

import './BaseAdapterScript.sol';

abstract contract BaseLZAdapter is BaseAdapterScript {
  function LZ_ENDPOINT() public view virtual returns (address);

  function isTestNet() public view virtual returns (bool) {
    return false;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    address lzAdapter;
    if (isTestNet()) {
      lzAdapter = address(
        new LayerZeroAdapterTestnet(
          LZ_ENDPOINT(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      lzAdapter = address(
        new LayerZeroAdapter(
          LZ_ENDPOINT(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
    addresses.lzAdapter = lzAdapter;
  }
}

// https://docs.layerzero.network/contracts/endpoint-addresses#ethereum
contract Ethereum is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);
    remoteNetworks[0] = ChainIds.POLYGON;
    remoteNetworks[1] = ChainIds.BNB;

    return remoteNetworks;
  }
}

// https://docs.layerzero.network/contracts/endpoint-addresses#sepolia-testnet
contract Ethereum_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);
    remoteNetworks[0] = TestNetChainIds.POLYGON_MUMBAI;
    remoteNetworks[1] = TestNetChainIds.BNB_TESTNET;

    return remoteNetworks;
  }
}

// https://docs.layerzero.network/contracts/endpoint-addresses#polygon
contract Polygon is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

// https://docs.layerzero.network/contracts/endpoint-addresses#mumbai-polygon-testnet
contract Polygon_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
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

// https://docs.layerzero.network/contracts/endpoint-addresses#bnb-chain
contract Binance is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

// https://docs.layerzero.network/contracts/endpoint-addresses#bnb-chain-testnet
contract Binance_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
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
