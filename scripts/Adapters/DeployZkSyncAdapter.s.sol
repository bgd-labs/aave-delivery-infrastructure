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

  function REFUND_ADDRESS() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (TESTNET()) {
      addresses.zksyncAdapter = address(
        new ZkSyncAdapterTestnet(
          addresses.crossChainController,
          MAILBOX(),
          REFUND_ADDRESS(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      addresses.zksyncAdapter = address(
        new ZkSyncAdapter(
          addresses.crossChainController,
          MAILBOX(),
          REFUND_ADDRESS(),
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

  function REFUND_ADDRESS() public view override returns (address) {
    DeployerHelpers.Addresses memory remoteAddresses = _getAddresses(ChainIds.ZK_SYNC);
    return remoteAddresses.crossChainController;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x32400084C286CF3E17e7B677ea9583e60a000324;
  }
}

contract Ethereum_testnet is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REFUND_ADDRESS() public view override returns (address) {
    DeployerHelpers.Addresses memory remoteAddresses = _getAddresses(
      TestNetChainIds.ZK_SYNC_SEPOLIA
    );
    return remoteAddresses.crossChainController;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x9A6DE0f62Aa270A8bCB1e2610078650D539B1Ef9;
  }

  function TESTNET() public pure override returns (bool) {
    return true;
  }
}

contract Zksync is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ZK_SYNC;
  }

  function REFUND_ADDRESS() public pure override returns (address) {
    return address(0);
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x32400084C286CF3E17e7B677ea9583e60a000324;
  }
}

contract Zksync_testnet is BaseZkSyncAdapter {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ZK_SYNC_SEPOLIA;
  }

  function REFUND_ADDRESS() public pure override returns (address) {
    return address(0);
  }

  function REMOTE_NETWORKS() public view override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;
    return remoteNetworks;
  }

  function MAILBOX() public pure override returns (address) {
    return 0x9A6DE0f62Aa270A8bCB1e2610078650D539B1Ef9;
  }

  function TESTNET() public pure override returns (bool) {
    return true;
  }
}
