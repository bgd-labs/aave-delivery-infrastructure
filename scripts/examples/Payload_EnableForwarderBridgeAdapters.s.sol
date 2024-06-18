// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

/**
 * @notice Deploys a payload with a single function that enables forwarder bridge adapters.
 *
 * @dev Remember to update the adaptersToEnable array length and members.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_EnableForwarderBridgeAdapters.s.s.sol --tc CreateEnableForwarderBridgeAdaptersPayload
 */
contract EnableForwarderBridgeAdaptersPayload {
  /// @dev Replace with the address of the CrossChainForwarder contract.
  ICrossChainForwarder constant FORWARDER = ICrossChainForwarder(address(0));

  function execute() external {
    /// @dev Replace with the forwarder bridge adapters to enable.
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory adaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0);
    // adaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: address(0),
    //   destinationBridgeAdapter: address(0),
    //   destinationChainId: 0
    // });

    FORWARDER.enableBridgeAdapters(adaptersToEnable);
  }
}

contract CreateEnableForwarderBridgeAdaptersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    EnableForwarderBridgeAdaptersPayload enableForwarderBridgeAdaptersPayload = new EnableForwarderBridgeAdaptersPayload();
    console2.log(
      'EnableForwarderBridgeAdaptersPayload deployed at %s on chain with chain ID %s',
      address(enableForwarderBridgeAdaptersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
