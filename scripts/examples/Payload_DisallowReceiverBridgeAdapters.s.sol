// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

/**
 * @notice Deploys a payload with a single function that disallows receiver bridge adapters.
 *
 * @dev Remember to update the receiver address and disallowAdapterInputs array length and members.
 * An example is provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_DisallowReceiverBridgeAdapters.s.s.sol --tc CreateReceiverDisallowBridgeAdaptersPayload
 */
contract ReceiverDisallowBridgeAdaptersPayload {
  /// @dev Replace with the address of the CrossChainReceiver contract.
  ICrossChainReceiver constant RECEIVER = ICrossChainReceiver(address(0));

  function execute() external {
    /// @dev Replace with the adapters and associated chain IDs.
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory disallowAdapterInputs = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0);
    // disallowAdapterInputs[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    RECEIVER.disallowReceiverBridgeAdapters(disallowAdapterInputs);
  }
}

contract CreateReceiverDisallowBridgeAdaptersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    ReceiverDisallowBridgeAdaptersPayload receiverDisallowBridgeAdaptersPayload = new ReceiverDisallowBridgeAdaptersPayload();
    console2.log(
      'ReceiverDisallowBridgeAdaptersPayload deployed at %s on chain with chain ID %s',
      address(receiverDisallowBridgeAdaptersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
