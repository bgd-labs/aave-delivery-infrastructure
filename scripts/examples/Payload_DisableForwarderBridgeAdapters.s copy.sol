// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

/**
 * @notice Deploys a payload with a single function that disables forwarder bridge adapters.
 *
 * @dev Remember to update the adaptersToDisable array length and members.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_DisableForwarderBridgeAdapters.s.s.sol --tc CreateDisableForwarderBridgeAdaptersPayload
 */
contract DisableForwarderBridgeAdaptersPayload {
  /// @dev Replace with the address of the CrossChainForwarder contract.
  ICrossChainForwarder constant FORWARDER = ICrossChainForwarder(address(0));

  function execute() external {
    /// @dev Replace with the forwarder bridge adapters to disable.
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory adaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    // adaptersToDisable[0] = ICrossChainForwarder.BridgeAdapterToDisable({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    FORWARDER.disableBridgeAdapters(adaptersToDisable);
  }
}

contract CreateDisableForwarderBridgeAdaptersPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    DisableForwarderBridgeAdaptersPayload disableForwarderBridgeAdaptersPayload = new DisableForwarderBridgeAdaptersPayload();
    console2.log(
      'DisableForwarderBridgeAdaptersPayload deployed at %s on chain with chain ID %s',
      address(disableForwarderBridgeAdaptersPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
