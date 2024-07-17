// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

/**
 * @notice Deploys a payload with a single function that updates receiver confirmations.
 *
 * @dev Remember to update the receiver address and confirmationInputs array length and members.
 * An example is provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_ReceiverConfirmations.s.sol --tc CreateReceiverConfirmationsPayload
 */
contract ReceiverConfirmationsPayload {
  /// @dev Replace with the address of the CrossChainReceiver contract.
  ICrossChainReceiver constant RECEIVER = ICrossChainReceiver(address(0));

  function execute() external {
    /// @dev Replace with the chain IDs and required confirmations.
    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationInputs = new ICrossChainReceiver.ConfirmationInput[](0);
    // confirmationInputs[0] = ICrossChainReceiver.ConfirmationInput({
    //   chainId: 1,
    //   requiredConfirmations: 1
    // });

    RECEIVER.updateConfirmations(confirmationInputs);
  }
}

contract CreateReceiverConfirmationsPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    ReceiverConfirmationsPayload receiverConfirmationsPayload = new ReceiverConfirmationsPayload();
    console2.log(
      'ReceiverConfirmationsPayload deployed at %s on chain with chain ID %s',
      address(receiverConfirmationsPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
