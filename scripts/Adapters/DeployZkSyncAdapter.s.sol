// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {ZkSyncAdapter} from '../../src/contracts/adapters/zkSync/ZkSyncAdapter.sol';
import {ZkSyncAdapterTestnet} from '../contract_extensions/ZkSyncAdapterTestnet.sol';

abstract contract BaseZkSyncAdapter is BaseAdapterScript {
  function MAILBOX() public view virtual returns (address);

  function TESTNET() public view virtual returns (bool) {
    return false;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (TESTNET()) {
      addresses.zksyncAdapter = address(
        new ZkSyncAdapterTestnet(
          addresses.crossChainController,
          MAILBOX(),
          addresses.crossChainController, // refund address
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      addresses.zksyncAdapter = address(
        new ZkSyncAdapter(
          addresses.crossChainController,
          MAILBOX(),
          addresses.crossChainController, // refund address
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
  }
}

contract Ethereum is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x63b5EC36B09384fFA7106A80Ec7cfdFCa521fD08;
  }
}

contract Ethereum_testnet is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x2eD8eF54a16bBF721a318bd5a5C0F39Be70eaa65;
  }

  function TESTNET() public pure override returns (bool) {
    return true;
  }
}

contract Zksync is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ZK_SYNC;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x63b5EC36B09384fFA7106A80Ec7cfdFCa521fD08;
  }
}

contract Zksync_testnet is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ZK_SYNC_SEPOLIA;
  }

  function REMOTE_NETWORKS() public view override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;
    console.log('chainid 1', remoteNetworks[0]);
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x2eD8eF54a16bBF721a318bd5a5C0F39Be70eaa65;
  }

  function TESTNET() public pure override returns (bool) {
    return true;
  }
}
