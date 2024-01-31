// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {OpAdapter, IOpAdapter, IBaseAdapter} from '../../src/contracts/adapters/optimism/OpAdapter.sol';
import {OptimismAdapterTestnet} from '../contract_extensions/OptimismAdapter.sol';

contract DeployOpAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.optimismAdapter.remoteNetworks;
  }

  function _deployAdapter(
    address crossChainController,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(trustedRemotes.length > 0, 'Adapter needs trusted remotes');
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory opConfig = config.adapters.optimismAdapter;
    require(opConfig.endpoint != address(0), 'Optimism ovm can not be 0');

    address opAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      opAdapter = address(
        new OptimismAdapterTestnet(crossChainController, opConfig.endpoint, trustedRemotes)
      );
    } else {
      opAdapter = address(new OpAdapter(crossChainController, opConfig.endpoint, trustedRemotes));
    }

    currentAddresses.opAdapter = revisionAddresses.opAdapter = opAdapter;
  }
}

//{
//ethereum_ovm: 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1,
//optimism_ovm: 0x4200000000000000000000000000000000000007
//}
