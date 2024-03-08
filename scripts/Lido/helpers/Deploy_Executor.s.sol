// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Executor} from "../Executor/Executor.sol";

import '../BaseScript.sol';

abstract contract BaseExecutor is BaseScript {
  function getDaoAgentAddress() public view virtual returns (address) {
    return address(0);
  }

  function getDaoAgentChainId() public view virtual returns (uint256) {
    return 0;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.executor = address(new Executor(
      addresses.crossChainController,
      getDaoAgentAddress(),
      getDaoAgentChainId(),
      0,
      86400,
      0,
      1,
      address(0)
    ));
  }
}

abstract contract MainnetExecutor is BaseExecutor {
  function getDaoAgentAddress() public view virtual override returns (address) {
    return 0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c;
  }

  function getDaoAgentChainId() public view virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is MainnetExecutor {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is MainnetExecutor {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }
}

abstract contract TestnetExecutor is BaseExecutor {
  function getDaoAgentAddress() public view virtual override returns (address) {
    return _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA).owner; // Temporary use of owner address
  }

  function getDaoAgentChainId() public view virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is TestnetExecutor {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Binance_testnet is TestnetExecutor {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}
