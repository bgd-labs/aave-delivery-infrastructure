// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CCIPAdapter, ICCIPAdapter, IBaseAdapter} from '../../src/contracts/adapters/ccip/CCIPAdapter.sol';
import './BaseAdapterScript.sol';
import {CCIPAdapterTestnet} from '../contract_extensions/CCIPAdapter.sol';

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
          trustedRemotes,
          LINK_TOKEN()
        )
      );
    } else {
      addresses.ccipAdapter = address(
        new CCIPAdapter(addresses.crossChainController, CCIP_ROUTER(), trustedRemotes, LINK_TOKEN())
      );
    }
  }
}

contract Ethereum is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0xE561d5E02207fb5eB32cca20a699E0d8919a1476;
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
    remoteNetworks[1] = ChainIds.AVALANCHE;

    return remoteNetworks;
  }
}

contract Ethereum_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0xD0daae2231E9CB96b94C8512223533293C3693Bf;
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
    remoteNetworks[1] = TestNetChainIds.AVALANCHE_FUJI;

    return remoteNetworks;
  }
}

contract Avalanche is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x27F39D0af3303703750D4001fCc1844c6491563c;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x5947BB275c521040051D82396192181b413227A3;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }
}

contract Avalanche_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
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

contract Polygon is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x3C3D92629A02a8D95D5CB9650fe49C3544f69B43;
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

contract Polygon_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x70499c328e1E2a3c41108bd3730F6670a44595D1;
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

contract Binance is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x536d7E53D0aDeB1F20E7c81fea45d02eC9dBD698;
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

contract Binance_testnet is BaseCCIPAdapter {
  function CCIP_ROUTER() public pure override returns (address) {
    return 0x9527E2d01A3064ef6b50c1Da1C0cC523803BCFF2;
  }

  function LINK_TOKEN() public pure override returns (address) {
    return 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }
}
