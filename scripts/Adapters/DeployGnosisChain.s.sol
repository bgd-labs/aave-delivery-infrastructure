// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GnosisChainAdapter} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';
import {BaseAdapterScript, DeployerHelpers, IBaseAdapter, ChainIds, TestNetChainIds} from './BaseAdapterScript.sol';

address constant AMB_BRIDGE_ETHEREUM = 0x4C36d2919e407f0Cc2Ee3c993ccF8ac26d9CE64e;
address constant AMB_BRIDGE_GOERLI = 0x87A19d769D875964E9Cd41dDBfc397B2543764E6;
address constant AMB_BRIDGE_GNOSIS = 0x75Df5AF045d91108662D8080fD1FEFAd6aA0bb59;
address constant AMB_BRIDGE_CHIADO = 0x99Ca51a3534785ED619f46A79C7Ad65Fa8d85e7a;

abstract contract BaseGnosisChainAdapter is BaseAdapterScript {
  function GNOSIS_AMB_BRIDGE() public pure virtual returns (address);
}

contract Ethereum is BaseGnosisChainAdapter {
  function GNOSIS_AMB_BRIDGE() public pure override returns (address) {
    return AMB_BRIDGE_ETHEREUM;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.gnosisAdapter = address(
      new GnosisChainAdapter(
        addresses.crossChainController,
        GNOSIS_AMB_BRIDGE(),
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

// careful as this is deployed on goerli
contract Ethereum_testnet is BaseGnosisChainAdapter {
  function GNOSIS_AMB_BRIDGE() public pure override returns (address) {
    return AMB_BRIDGE_GOERLI;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_GOERLI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](0);
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.gnosisAdapter = address(
      new GnosisChainAdapter(
        addresses.crossChainController,
        GNOSIS_AMB_BRIDGE(),
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

contract Gnosis is BaseGnosisChainAdapter {
  function GNOSIS_AMB_BRIDGE() public pure override returns (address) {
    return AMB_BRIDGE_GNOSIS;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.gnosisAdapter = address(
      new GnosisChainAdapter(
        addresses.crossChainController,
        GNOSIS_AMB_BRIDGE(),
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}

// careful as the path is with goerli
contract Gnosis_testnet is BaseGnosisChainAdapter {
  function GNOSIS_AMB_BRIDGE() public pure override returns (address) {
    return AMB_BRIDGE_CHIADO;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;
    return remoteNetworks;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    addresses.gnosisAdapter = address(
      new GnosisChainAdapter(
        addresses.crossChainController,
        GNOSIS_AMB_BRIDGE(),
        GET_BASE_GAS_LIMIT(),
        trustedRemotes
      )
    );
  }
}
