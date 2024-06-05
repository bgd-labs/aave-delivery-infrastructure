// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SameChainAdapter} from '../../src/contracts/adapters/sameChain/SameChainAdapter.sol';
import '../BaseScript.sol';

abstract contract DeploySameChainAdapter is BaseScript {
  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.sameChainAdapter = address(new SameChainAdapter());
  }
}

contract Ethereum is DeploySameChainAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Ethereum_testnet is DeploySameChainAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
