// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {MetisAdapter, IBaseAdapter} from '../../src/contracts/adapters/metis/MetisAdapter.sol';
import {MetisAdapterTestnet} from '../contract_extensions/MetisAdapter.sol';

contract DeployMetisAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.metisAdapter.remoteNetworks;
  }

  function _deployAdapter(
    address crossChainController,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory metisConfig = config.adapters.metisAdapter;
    require(metisConfig.endpoint != address(0), 'Metis ovm can not be 0');

    address metisAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      metisAdapter = address(
        new MetisAdapterTestnet(crossChainController, metisConfig.endpoint, trustedRemotes)
      );
    } else {
      metisAdapter = address(
        new MetisAdapter(crossChainController, metisConfig.endpoint, trustedRemotes)
      );
    }

    currentAddresses.metisAdapter = revisionAddresses.metisAdapter = metisAdapter;
  }
}

//{
//ethereum_ovm: 0x081D1101855bD523bA69A9794e0217F0DB6323ff,
//optimism_ovm: 0x4200000000000000000000000000000000000007
//}
