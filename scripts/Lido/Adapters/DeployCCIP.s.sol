// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CCIPAdapter, ICCIPAdapter, IBaseAdapter} from '../../../src/contracts/adapters/ccip/CCIPAdapter.sol';
import {CCIPAdapterTestnet} from '../../contract_extensions/CCIPAdapter.sol';

import './BaseAdapterScript.sol';

abstract contract BaseCCIPAdapter is BaseAdapterScript {
  function CCIP_ROUTER() public view virtual returns (address);

  function LINK_TOKEN() public view virtual returns (address);

  function isTestNet() public view virtual returns (bool) {
    return false;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestNet()) {
      addresses.ccipAdapter = address(
        new CCIPAdapterTestnet(
          addresses.crossChainController,
          CCIP_ROUTER(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes,
          LINK_TOKEN()
        )
      );
    } else {
      addresses.ccipAdapter = address(
        new CCIPAdapter(
          addresses.crossChainController,
          CCIP_ROUTER(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes,
          LINK_TOKEN()
        )
      );
    }
  }
}

// https://docs.chain.link/ccip/supported-networks/v1_2_0/mainnet#ethereum-mainnet
contract Ethereum is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x80226fc0Ee2b096224EeAc085Bb9a8cba1146f7D;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x514910771AF9Ca656af840dff83E8264EcF986CA;
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

// https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-sepolia
contract Ethereum_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x779877A7B0D9E8603169DdbD7836e478b4624789;
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

// https://docs.chain.link/ccip/supported-networks/v1_2_0/mainnet#polygon-mainnet
contract Polygon is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x849c5ED5a80F5B408Dd4969b78c2C8fdf0565Bfe;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;
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

// https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#polygon-mumbai
contract Polygon_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x1035CabC275068e0F4b745A29CEDf38E13aF41b1;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
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

// https://docs.chain.link/ccip/supported-networks/v1_2_0/mainnet#bnb-mainnet
contract Binance is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x34B03Cb9086d7D758AC55af71584F81A598759FE;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
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

// https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#bnb-testnet
contract Binance_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
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
