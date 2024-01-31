// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {HyperLaneAdapter, IHyperLaneAdapter, IBaseAdapter} from '../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';

contract DeployHLAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.hlAdapter.remoteNetworks;
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

    HyperlaneAdapterInfo memory hlConfig = config.adapters.hlAdapter;
    require(hlConfig.mailBox != address(0), 'Hyperlane mail box can not be 0');
    require(hlConfig.igp != address(0), 'Hyperlane igp can not be 0');

    address hlAdapter = address(
      new HyperLaneAdapter(crossChainController, hlConfig.mailBox, hlConfig.igp, trustedRemotes)
    );

    currentAddresses.hlAdapter = revisionAddresses.hlAdapter = hlAdapter;
  }
}
