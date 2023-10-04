// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';


contract DeployReceiver is Script {
  function run() external {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    console2.log(address(new MockReceiver()));
  }
}

contract MockReceiver {
  event StateUpdate(uint256 indexed originChainId, uint256 indexed newState);
  event MessageReceived(string message);
  uint256 public state;

  function receiveCrossChainMessage(bytes memory payload, uint256 originChainId) external {
    emit StateUpdate(originChainId, ++state);
    emit MessageReceived(string(payload));
  }
}