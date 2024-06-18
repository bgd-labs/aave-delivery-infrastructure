// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

/**
 * @notice Deploys a payload with a single function that approves forwarder senders.
 *
 * @dev Remember to update the sendersToApprove array length and members.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_ApproveForwarderSenders.s.s.sol --tc CreateApproveForwarderSendersPayload
 */
contract ApproveForwarderSendersPayload {
  /// @dev Replace with the address of the CrossChainForwarder contract.
  ICrossChainForwarder constant FORWARDER = ICrossChainForwarder(address(0));

  function execute() external {
    /// @dev Replace with the senders to approve.
    address[] memory sendersToApprove = new address[](0);
    // sendersToApprove[0] = adress(0);

    FORWARDER.approveSenders(sendersToApprove);
  }
}

contract CreateApproveForwarderSendersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    ApproveForwarderSendersPayload approveForwarderSendersPayload = new ApproveForwarderSendersPayload();
    console2.log(
      'ApproveForwarderSendersPayload deployed at %s on chain with chain ID %s',
      address(approveForwarderSendersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
