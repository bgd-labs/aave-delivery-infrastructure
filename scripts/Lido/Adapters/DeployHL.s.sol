// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {HyperLaneAdapter, IHyperLaneAdapter, IBaseAdapter} from '../../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';

import './BaseAdapterScript.sol';

// https://docs.hyperlane.xyz/docs/reference/contract-addresses
abstract contract BaseHLAdapter is BaseAdapterScript {
  function HL_MAIL_BOX() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.hlAdapter = address(
      new HyperLaneAdapter(
        addresses.crossChainController,
        HL_MAIL_BOX(),
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

contract Ethereum is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xc005dc82818d67AF737725bD4bf75435d065D239;
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

contract Ethereum_testnet is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);

    remoteNetworks[0] = TestNetChainIds.POLYGON_MUMBAI;
    remoteNetworks[1] = TestNetChainIds.BNB_TESTNET;

    return remoteNetworks;
  }
}

contract Polygon is BaseHLAdapter {
  function HL_MAIL_BOX() public pure override returns (address) {
    return 0x5d934f4e2f797775e53561bB72aca21ba36B96BB;
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
    return 0x2d1889fe5B092CD988972261434F7E5f26041115;
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
    return 0x2971b9Aec44bE4eb673DF1B88cDB57b96eefe8a4;
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
    return 0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D;
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
