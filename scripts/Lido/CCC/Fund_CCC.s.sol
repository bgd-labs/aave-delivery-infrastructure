// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';

abstract contract BaseFundCrossChainController is BaseScript {
  function getAmountToFund() public view virtual returns (uint256) {
    return 100000000000000000;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    (bool success, ) = addresses.crossChainController.call{value: getAmountToFund()}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }
}

contract Ethereum is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Ethereum_testnet is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Binance_testnet is BaseFundCrossChainController {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}
