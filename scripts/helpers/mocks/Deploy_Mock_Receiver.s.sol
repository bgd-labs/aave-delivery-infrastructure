// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../BaseScript.sol';
import {MockReceiver} from './MockReceiver.sol';

contract Zksync_testnet is BaseScript {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ZK_SYNC_SEPOLIA;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    new MockReceiver();
  }
}
