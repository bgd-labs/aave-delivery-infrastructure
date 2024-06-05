// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import {ChainIds, TestNetChainIds} from 'aave-helpers/ChainIds.sol';
import {Create2Utils} from 'aave-helpers/ScriptUtils.sol';

abstract contract BaseScript is Script {
  function TRANSACTION_NETWORK() internal view virtual returns (uint256);
}
