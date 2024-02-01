// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {LayerZeroAdapter, ILayerZeroAdapter, IBaseAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {LayerZeroAdapterTestnet} from '../contract_extensions/LayerZeroAdapter.sol';

contract DeployLZAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.lzAdapter.remoteNetworks;
  }

  function _deployAdapter(
    address crossChainController,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory lzConfig = config.adapters.lzAdapter;
    require(lzConfig.endpoint != address(0), 'LayerZero endpoint can not be 0');

    address lzAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      lzAdapter = address(
        new LayerZeroAdapterTestnet(lzConfig.endpoint, crossChainController, trustedRemotes)
      );
    } else {
      lzAdapter = address(
        new LayerZeroAdapter(lzConfig.endpoint, crossChainController, trustedRemotes)
      );
    }
    currentAddresses.lzAdapter = revisionAddresses.lzAdapter = lzAdapter;
  }
}
