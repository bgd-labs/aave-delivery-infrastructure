// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {ICrossChainReceiver} from '../../../src/contracts/interfaces/ICrossChainReceiver.sol';

abstract contract BaseSetCCRAdapters is BaseScript {
  function getChainIds() public virtual returns (uint256[] memory);

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public view virtual returns (address[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    uint256[] memory chainIds = getChainIds();
    address[] memory receiverBridgeAdaptersToAllow = getReceiverBridgeAdaptersToAllow(addresses);

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
    memory bridgeAdapterConfig = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
      receiverBridgeAdaptersToAllow.length
    );

    for (uint256 i = 0; i < receiverBridgeAdaptersToAllow.length; i++) {
      bridgeAdapterConfig[i] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: receiverBridgeAdaptersToAllow[i],
        chainIds: chainIds
      });
    }

    ICrossChainReceiver(addresses.crossChainController).allowReceiverBridgeAdapters(
      bridgeAdapterConfig
    );
  }
}

contract Ethereum is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](2);
    chainIds[0] = ChainIds.POLYGON;
    chainIds[1] = ChainIds.BNB;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Polygon is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Binance is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Ethereum_testnet is Ethereum {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getChainIds() public pure override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](2);
    chainIds[0] = TestNetChainIds.POLYGON_MUMBAI;
    chainIds[1] = TestNetChainIds.BNB_TESTNET;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Polygon_testnet is Polygon {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Binance_testnet is Binance {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}
