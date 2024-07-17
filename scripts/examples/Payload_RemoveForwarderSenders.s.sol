// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

/**
 * @notice Deploys a payload with a single function that removes forwarder senders.
 *
 * @dev Remember to update the sendersToRemove array length and members.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_RemoveForwarderSenders.s.s.sol --tc CreateRemoveForwarderSendersPayload
 */
contract RemoveForwarderSendersPayload {
  /// @dev Replace with the address of the CrossChainForwarder contract.
  ICrossChainForwarder constant FORWARDER = ICrossChainForwarder(address(0));

  function execute() external {
    /// @dev Replace with the senders to remove.
    address[] memory sendersToRemove = new address[](0);
    // sendersToRemove[0] = adress(0);

    FORWARDER.removeSenders(sendersToRemove);
  }
}

contract CreateRemoveForwarderSendersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    RemoveForwarderSendersPayload removeForwarderSendersPayload = new RemoveForwarderSendersPayload();
    console2.log(
      'RemoveForwarderSendersPayload deployed at %s on chain with chain ID %s',
      address(removeForwarderSendersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
