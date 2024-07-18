// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';
import {IEmergencyRegistry} from '../../src/contracts/emergency/interfaces/IEmergencyRegistry.sol';

/**
 * @notice Deploys a payload with a single `execute()` function that enables emergency mode
 * on the given chains.
 *
 * @dev Remember to update the emergency registry address and the emergencyChains array length and members.
 * Examples are provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_Emergency.s.sol --tc CreateEmergencyPayload
 */
contract EmergencyPayload {
  /// @dev Replace with the address of the EmergencyRegistry contract.
  IEmergencyRegistry constant EMERGENCY_REGISTRY = IEmergencyRegistry(address(0));

  function execute() external {
    /// @dev Replace with the chains to enable emergency mode on.
    // Replace the "0" with the number of chains, then set each one like in the comment.
    uint256[] memory emergencyChains = new uint256[](0);
    // emergencyChains[0] = 1;
    // emergencyChains[1] = 2;

    EMERGENCY_REGISTRY.setEmergency(emergencyChains);
  }
}

contract CreateEmergencyPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    EmergencyPayload emergencyPayload = new EmergencyPayload();
    console2.log(
      'EmergencyPayload deployed at %s on chain with chain ID %s',
      address(emergencyPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
