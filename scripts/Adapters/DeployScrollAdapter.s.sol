// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {ScrollAdapter, IBaseAdapter} from '../../src/contracts/adapters/scroll/ScrollAdapter.sol';
import {ScrollAdapterTestnet} from '../contract_extensions/ScrollAdapter.sol';

contract DeployScrollAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.scrollAdapter.remoteNetworks;
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

    EndpointAdapterInfo memory scrollConfig = config.adapters.scrollAdapter;
    require(scrollConfig.endpoint != address(0), 'Scroll ovm can not be 0');

    address scrollAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      scrollAdapter = address(
        new ScrollAdapterTestnet(crossChainController, scrollConfig.endpoint, trustedRemotes)
      );
    } else {
      scrollAdapter = address(
        new ScrollAdapter(crossChainController, scrollConfig.endpoint, trustedRemotes)
      );
    }

    currentAddresses.scrollAdapter = revisionAddresses.scrollAdapter = scrollAdapter;
  }
}

//{
//ethereum_ovm: 0x6774Bcbd5ceCeF1336b5300fb5186a12DDD8b367,
//scroll_ovm: 0x781e90f1c8Fc4611c9b7497C3B47F99Ef6969CbC
//}
