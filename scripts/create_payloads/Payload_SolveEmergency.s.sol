// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/console2.sol';
import {IEmergencyRegistry} from '../../src/contracts/emergency/interfaces/IEmergencyRegistry.sol';

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../../src/contracts/interfaces/ICrossChainControllerWithEmergencyMode.sol';

/**
 * @notice Deploys a payload with a single function that solves the emergency.
 *
 * @dev Note that this should only be used to create the calldata necessary to pass to the
 * controller, as the Guardian must solve the emergency, not governance.
 *
 * Remember to set the correct parameters, including the controller address and array lengths and members.
 * Examples are provided.
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_SolveEmergency.s.sol --tc CreateSolveEmergencyPayload
 */
contract SolveEmergencyPayload {
  /// @dev Replace with the address of the CrossChainControllerWithEmergencyMode contract.
  ICrossChainControllerWithEmergencyMode constant CONTROLLER =
    ICrossChainControllerWithEmergencyMode(address(0));

  function execute() external {
    /// @dev Replace the length and contents of all parameters.

    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationInputs = new ICrossChainReceiver.ConfirmationInput[](0);
    // confirmationInputs[0] = ICrossChainReceiver.ConfirmationInput({
    //   chainId: 1,
    //   requiredConfirmations: 1
    // });

    ICrossChainReceiver.ValidityTimestampInput[]
      memory validityTimestampInputs = new ICrossChainReceiver.ValidityTimestampInput[](0);
    // validityTimestampInputs[0] = ICrossChainReceiver.ValidityTimestampInput({
    //   chainId: 1,
    //   validityTimestamp: 1
    // });

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        0
      );
    // receiverBridgeAdaptersToAllow[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToDisallow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        0
      );
    // receiverBridgeAdaptersToDisallow[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    address[] memory sendersToApprove = new address[](0);
    address[] memory sendersToRemove = new address[](0);

    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        0
      );
    // forwarderBridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: address(0),
    //   destinationBridgeAdapter: address(0),
    //   destinationChainId: 1
    // });

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarderBridgeAdaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](
        0
      );
    // forwarderBridgeAdaptersToDisable[0] = ICrossChainForwarder.BridgeAdapterToDisable({
    //   bridgeAdapter: address(0),
    //   chainIds: new uint256[](0)
    // });

    ICrossChainForwarder.RequiredConfirmationsByReceiverChain[]
      memory requiredConfirmationsByReceiverChain = new ICrossChainForwarder.RequiredConfirmationsByReceiverChain[](
        0
      );

    CONTROLLER.solveEmergency(
      confirmationInputs,
      validityTimestampInputs,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable,
      requiredConfirmationsByReceiverChain
    );
  }
}

contract CreateSolveEmergencyPayload is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    SolveEmergencyPayload solveEmergencyPayload = new SolveEmergencyPayload();
    console2.log(
      'SolveEmergencyPayload deployed at %s on chain with chain ID %s',
      address(solveEmergencyPayload),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
