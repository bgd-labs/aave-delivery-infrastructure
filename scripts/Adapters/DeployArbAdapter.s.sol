//// SPDX-License-Identifier: BUSL-1.1
//pragma solidity ^0.8.0;
//
//import {ArbAdapter, IArbAdapter, IBaseAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
//import './BaseAdapterScript.sol';
//import {ArbitrumAdapterTestnet} from '../contract_extensions/ArbitrumAdapter.sol';
//
//abstract contract BaseArbAdapter is BaseAdapterScript {
//  function INBOX() public view virtual returns (address);
//
//  function DESTINATION_CCC() public view virtual returns (address);
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
//      addresses.arbAdapter = address(
//        new ArbitrumAdapterTestnet(
//          addresses.crossChainController,
//          INBOX(),
//          DESTINATION_CCC(),
//          trustedRemotes
//        )
//      );
//    } else {
//      addresses.arbAdapter = address(
//        new ArbAdapter(addresses.crossChainController, INBOX(), DESTINATION_CCC(), trustedRemotes)
//      );
//    }
//  }
//}
//
//contract Ethereum is BaseArbAdapter {
//  function INBOX() public pure override returns (address) {
//    return 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;
//  }
//
//  function DESTINATION_CCC() public view override returns (address) {
//    return _getAddresses(ChainIds.ARBITRUM).crossChainController;
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
//contract Arbitrum is BaseArbAdapter {
//  function INBOX() public pure override returns (address) {
//    return address(0); // can be 0 as it will not be used to send or receive
//  }
//
//  function DESTINATION_CCC() public pure override returns (address) {
//    return address(0); // can be 0 as it will not be used to send or receive
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return ChainIds.ARBITRUM;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](1);
//    remoteNetworks[0] = ChainIds.ETHEREUM;
//    return remoteNetworks;
//  }
//}
//
//contract Ethereum_testnet is BaseArbAdapter {
//  function INBOX() public pure override returns (address) {
//    return 0x6BEbC4925716945D46F0Ec336D5C2564F419682C;
//  }
//
//  function isTestnet() public pure override returns (bool) {
//    return true;
//  }
//
//  function DESTINATION_CCC() public view override returns (address) {
//    return _getAddresses(TestNetChainIds.ARBITRUM_GOERLI).crossChainController;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ETHEREUM_GOERLI;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](0);
//
//    return remoteNetworks;
//  }
//}
//
//contract Arbitrum_testnet is BaseArbAdapter {
//  function INBOX() public pure override returns (address) {
//    return address(0); // can be 0 as it will not be used to send or receive
//  }
//
//  function isTestnet() public pure override returns (bool) {
//    return true;
//  }
//
//  function DESTINATION_CCC() public pure override returns (address) {
//    return address(0); // can be 0 as it will not be used to send or receive
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return TestNetChainIds.ARBITRUM_GOERLI;
//  }
//
//  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
//    uint256[] memory remoteNetworks = new uint256[](1);
//    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;
//    return remoteNetworks;
//  }
//}
