// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console2.sol';
import 'forge-std/StdUtils.sol';
import 'forge-std/Script.sol';

contract PrecomputeAddress is Script {
  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    address me = vm.addr(vm.envUint('PRIVATE_KEY'));
    address nextContract = StdUtils.computeCreateAddress(me, vm.getNonce(me));
    console2.log(nextContract);
  }
}
