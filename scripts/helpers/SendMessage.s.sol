//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
//import '../BaseScript.sol';
//import {ICrossChainController} from '../../src/contracts/interfaces/ICrossChainController.sol';
//
//abstract contract BaseSendMessage is BaseScript {
//  function DESTINATION_NETWORK() public pure virtual returns (uint256);
//
//  function GAS_LIMIT() public pure virtual returns (uint256) {
//    return 300_000;
//  }
//
//  function _execute(DeployerHelpers.Addresses memory originAddresses) internal override {
//    DeployerHelpers.Addresses memory destinationAddresses = _getAddresses(DESTINATION_NETWORK());
//    require(
//      destinationAddresses.mockDestination != address(0),
//      'No mock destination on the destination chain'
//    );
//    ICrossChainController crossChainController = ICrossChainController(
//      originAddresses.crossChainController
//    );
//    if (!crossChainController.isSenderApproved(msg.sender)) {
//      address[] memory senders = new address[](1);
//      senders[0] = msg.sender;
//      crossChainController.approveSenders(senders);
//    }
//    crossChainController.forwardMessage(
//      DESTINATION_NETWORK(),
//      destinationAddresses.mockDestination,
//      GAS_LIMIT(),
//      bytes('Hello world')
//    );
//  }
//}
//
//contract Ethereum_testnet is BaseSendMessage {
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ETHEREUM_SEPOLIA;
//  }
//
//  function DESTINATION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.SCROLL_SEPOLIA;
//  }
//}
