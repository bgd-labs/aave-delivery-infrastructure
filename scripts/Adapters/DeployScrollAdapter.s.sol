//// SPDX-License-Identifier: BUSL-1.1
//pragma solidity ^0.8.0;
//
//import {ScrollAdapter, IBaseAdapter} from '../../src/contracts/adapters/scroll/ScrollAdapter.sol';
//import './BaseAdapterScript.sol';
//import {ScrollAdapterTestnet} from '../contract_extensions/ScrollAdapter.sol';
//
//abstract contract BaseScrollAdapter is BaseAdapterScript {
//  function OVM() public view virtual returns (address);
//
//  function isTestnet() public view virtual returns (bool) {
//    return false;
//  }
//
//  function _deployAdapter(
//    DeployerHelpers.Addresses memory addresses,
//    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
//  ) internal override {
//    if (isTestnet()) {
//      addresses.scrollAdapter = address(
//        new ScrollAdapterTestnet(addresses.crossChainController, OVM(), trustedRemotes)
//      );
//    } else {
//      addresses.scrollAdapter = address(
//        new ScrollAdapter(addresses.crossChainController, OVM(), trustedRemotes)
//      );
//    }
//  }
//}
//
//contract Ethereum is BaseScrollAdapter {
//  function OVM() public pure override returns (address) {
//    return 0x6774Bcbd5ceCeF1336b5300fb5186a12DDD8b367;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return ChainIds.ETHEREUM;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](0);
//
//    return remoteNetworks;
//  }
//}
//
//contract Scroll is BaseScrollAdapter {
//  function OVM() public pure override returns (address) {
//    return 0x781e90f1c8Fc4611c9b7497C3B47F99Ef6969CbC;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return ChainIds.SCROLL;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](1);
//    remoteNetworks[0] = ChainIds.ETHEREUM;
//
//    return remoteNetworks;
//  }
//}
//
//contract Ethereum_testnet is BaseScrollAdapter {
//  function OVM() public pure override returns (address) {
//    return 0x50c7d3e7f7c656493D1D76aaa1a836CedfCBB16A;
//  }
//
//  function isTestnet() public pure override returns (bool) {
//    return true;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ETHEREUM_SEPOLIA;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](0);
//
//    return remoteNetworks;
//  }
//}
//
//contract Scroll_testnet is BaseScrollAdapter {
//  function OVM() public pure override returns (address) {
//    return 0xBa50f5340FB9F3Bd074bD638c9BE13eCB36E603d;
//  }
//
//  function isTestnet() public pure override returns (bool) {
//    return true;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.SCROLL_SEPOLIA;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](1);
//    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;
//
//    return remoteNetworks;
//  }
//}
