// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../contract_extensions/MockDestination.sol';

import '../BaseScript.sol';

abstract contract BaseMockDestination is BaseScript {
  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.mockDestination = address(new MockDestination(addresses.crossChainController));
  }
}

contract Ethereum is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Ethereum_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Binance_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}
