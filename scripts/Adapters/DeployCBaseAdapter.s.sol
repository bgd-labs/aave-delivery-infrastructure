// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {CBaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/cBase/CBaseAdapter.sol';
import {CBaseAdapterTestnet} from '../contract_extensions/CBAdapter.sol';

contract DeployCBAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.baseAdapter.remoteNetworks;
  }

  function _deployAdapter(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(trustedRemotes.length > 0, 'Adapter needs trusted remotes');
    address crossChainController = _getCrossChainController(
      currentAddresses,
      revisionAddresses,
      config.chainId
    );
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory baseConfig = config.adapters.baseAdapter;
    require(baseConfig.endpoint != address(0), 'Base ovm can not be 0');

    address baseAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      baseAdapter = address(
        new CBaseAdapterTestnet(crossChainController, baseConfig.endpoint, trustedRemotes)
      );
    } else {
      baseAdapter = address(
        new CBaseAdapter(crossChainController, baseConfig.endpoint, trustedRemotes)
      );
    }

    currentAddresses.baseAdapter = revisionAddresses.baseAdapter = baseAdapter;
  }
}

//{
//ethereum_ovm: 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa,
//optimism_ovm: 0x4200000000000000000000000000000000000007
//}
