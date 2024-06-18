// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

/**
 * @notice Deploys a payload with a single function that updates receiver message validity timestamps.
 *
 * @dev Remember to update the receiver address and validityTimestampInputs array length and members.
 * An example is provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_MessageValidity.s.sol --tc CreateMessageValidityPayload
 */
contract MessageValidityPayload {
  /// @dev Replace with the address of the CrossChainReceiver contract.
  ICrossChainReceiver constant RECEIVER = ICrossChainReceiver(address(0));

  function execute() external {
    ICrossChainReceiver.ValidityTimestampInput[]
      memory validityTimestampInputs = new ICrossChainReceiver.ValidityTimestampInput[](0);
    // validityTimestampInputs[0] = ICrossChainReceiver.ValidityTimestampInput({
    //   chainId: 1,
    //   validityTimestamp: 1
    // });

    RECEIVER.updateMessagesValidityTimestamp(validityTimestampInputs);
  }
}

contract CreateMessageValidityPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    MessageValidityPayload messagesValidityPayload = new MessageValidityPayload();
    console2.log(
      'MessageValidityPayload deployed at %s on chain with chain ID %s',
      address(messagesValidityPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
