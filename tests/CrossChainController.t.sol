// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseCrossChainController.t.sol';
import {CrossChainController, ICrossChainController} from '../src/contracts/CrossChainController.sol';

// contract CrossChainControllerTest is BaseCrossChainControllerTest {
//   function _deployControllerImplementation() internal override returns (address) {
//     return address(new CrossChainController());
//   }

//   function _getEncodedInitializer(
//     address owner,
//     address guardian,
//     ICrossChainReceiver.ConfirmationInput[] memory initialRequiredConfirmations,
//     ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
//     ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
//     address[] memory sendersToApprove
//   ) internal pure override returns (bytes memory) {
//     return
//       abi.encodeWithSelector(
//         ICrossChainController.initialize.selector,
//         owner,
//         guardian,
//         initialRequiredConfirmations,
//         receiverBridgeAdaptersToAllow,
//         forwarderBridgeAdaptersToEnable,
//         sendersToApprove
//       );
//   }
// }
