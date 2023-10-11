// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../../src/contracts/interfaces/ICrossChainControllerWithEmergencyMode.sol';
import "../BaseScript.sol";

abstract contract BaseSolveEmergency is BaseScript {
  function _execute(DeployerHelpers.Addresses memory addresses) internal override {

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

    ICrossChainControllerWithEmergencyMode(addresses.crossChainController).solveEmergency(
      confirmationInputs,
      validityTimestampInputs,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable
    );
  }
}

contract Polygon is BaseSolveEmergency {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseSolveEmergency {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Gnosis is BaseSolveEmergency {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Binance is BaseSolveEmergency {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}
