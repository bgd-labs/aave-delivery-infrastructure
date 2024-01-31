//// SPDX-License-Identifier: BUSL-1.1
//pragma solidity ^0.8.0;
//
//import '../BaseScript.sol';
//import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';
//
//abstract contract BaseSendMessageViaAdapter is BaseScript {
//  function REMOTE_NETWORK() public view virtual returns (uint256);
//
//  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
//    DeployerHelpers.Addresses memory remoteAddresses = _getAddresses(REMOTE_NETWORK());
//    bytes memory message = abi.encode('test message');
//    IBaseAdapter(addresses.zkevmAdapter).forwardMessage(
//      remoteAddresses.zkevmAdapter,
//      100_000,
//      remoteAddresses.chainId,
//      message
//    );
//  }
//}
//
//contract Ethereum_testnet is BaseSendMessageViaAdapter {
//  function REMOTE_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ETHEREUM_GOERLI;
//  }
//}
