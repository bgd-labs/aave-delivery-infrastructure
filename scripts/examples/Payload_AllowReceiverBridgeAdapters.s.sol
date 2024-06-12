// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

/**
 * @notice Deploys a payload with a single function that allows new receiver bridge adapters.
 *
 * @dev Remember to update the receiver address and allowAdapterInputs array length and members.
 * An example is provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_AllowReceiverBridgeAdapters.s.s.sol --tc CreateReceiverAllowBridgeAdaptersPayload
 */
contract ReceiverAllowBridgeAdaptersPayload {
  /// @dev Replace with the address of the CrossChainReceiver contract.
  ICrossChainReceiver constant RECEIVER = ICrossChainReceiver(address(0));

  function execute() external {
    /// @dev Replace with the adapters and associated chain IDs.
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory allowAdapterInputs = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0);
    // allowAdapterInputs[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    RECEIVER.allowReceiverBridgeAdapters(allowAdapterInputs);
  }
}

contract CreateReceiverAllowBridgeAdaptersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    ReceiverAllowBridgeAdaptersPayload receiverAllowBridgeAdaptersPayload = new ReceiverAllowBridgeAdaptersPayload();
    console2.log(
      'ReceiverAllowBridgeAdaptersPayload deployed at %s on chain with chain ID %s',
      address(receiverAllowBridgeAdaptersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
