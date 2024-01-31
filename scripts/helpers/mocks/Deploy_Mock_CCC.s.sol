//// SPDX-License-Identifier: BUSL-1.1
//pragma solidity ^0.8.0;
//
//import '../../../src/contracts/interfaces/IBaseReceiverPortal.sol';
//import '../../BaseScript.sol';
//
//contract MockCCC {
//  event MessageReceived(uint256 indexed originChainId, bytes message);
//
//  function receiveCrossChainMessage(
//    bytes memory encodedTransaction,
//    uint256 originChainId
//  ) external {
//    emit MessageReceived(originChainId, encodedTransaction);
//  }
//}
//
//abstract contract BaseDeployMockCCC is BaseScript {
//  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
//    addresses.crossChainController = address(new MockCCC());
//  }
//}
//
//contract Ethereum_testnet is BaseDeployMockCCC {
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ETHEREUM_GOERLI;
//  }
//}
//
//contract Zkevm_testnet is BaseDeployMockCCC {
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
//  }
//}
