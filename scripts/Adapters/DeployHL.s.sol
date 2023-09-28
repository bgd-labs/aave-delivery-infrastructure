// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {HyperLaneAdapter, IHyperLaneAdapter, IBaseAdapter} from '../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';
import './BaseAdapterScript.sol';

abstract contract BaseHLAdapter is BaseAdapterScript {
  function HL_MAIL_BOX() public view virtual returns (address);

  function HL_IGP() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.hlAdapter = address(
      new HyperLaneAdapter(addresses.crossChainController, HL_MAIL_BOX(), HL_IGP(), trustedRemotes)
    );
  }
}

contract Ethereum is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0x35231d4c2D8B8ADcB5617A638A0c4548684c7C70;
  }

  function HL_IGP() public pure override returns (address) {
    return 0x56f52c0A1ddcD557285f7CBc782D3d83096CE1Cc;
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

contract Ethereum_testnet is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xCC737a94FecaeC165AbCf12dED095BB13F037685;
  }

  function HL_IGP() public pure override returns (address) {
    return 0xF987d7edcb5890cB321437d8145E3D51131298b6;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);
    remoteNetworks[0] = TestNetChainIds.POLYGON_MUMBAI;
    remoteNetworks[1] = TestNetChainIds.AVALANCHE_FUJI;
    return remoteNetworks;
  }
}

contract Avalanche is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0x35231d4c2D8B8ADcB5617A638A0c4548684c7C70;
  }

  function HL_IGP() public pure override returns (address) {
    return 0x56f52c0A1ddcD557285f7CBc782D3d83096CE1Cc;
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

contract Avalanche_testnet is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xCC737a94FecaeC165AbCf12dED095BB13F037685;
  }

  function HL_IGP() public pure override returns (address) {
    return 0xF90cB82a76492614D07B82a7658917f3aC811Ac1;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;
    return remoteNetworks;
  }
}

contract Polygon is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0x35231d4c2D8B8ADcB5617A638A0c4548684c7C70;
  }

  function HL_IGP() public pure override returns (address) {
    return 0x56f52c0A1ddcD557285f7CBc782D3d83096CE1Cc;
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

contract Polygon_testnet is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xCC737a94FecaeC165AbCf12dED095BB13F037685;
  }

  function HL_IGP() public pure override returns (address) {
    return 0xF90cB82a76492614D07B82a7658917f3aC811Ac1;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;
    return remoteNetworks;
  }
}

contract Binance is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0x35231d4c2D8B8ADcB5617A638A0c4548684c7C70;
  }

  function HL_IGP() public pure override returns (address) {
    return 0x56f52c0A1ddcD557285f7CBc782D3d83096CE1Cc;
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

contract Binance_testnet is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xCC737a94FecaeC165AbCf12dED095BB13F037685;
  }

  function HL_IGP() public pure override returns (address) {
    return 0xF90cB82a76492614D07B82a7658917f3aC811Ac1;
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
