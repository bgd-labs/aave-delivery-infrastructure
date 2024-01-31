// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {PolygonAdapterEthereum} from '../../src/contracts/adapters/polygon/PolygonAdapterEthereum.sol';
import {PolygonAdapterPolygon} from '../../src/contracts/adapters/polygon/PolygonAdapterPolygon.sol';
import {PolygonAdapterGoerli, PolygonAdapterMumbai} from '../contract_extensions/PolygonAdapterTestnets.sol';

contract DeployPolygonAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.polAdapter.remoteNetworks;
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

    EndpointAdapterInfo memory polConfig = config.adapters.polAdapter;
    require(polConfig.endpoint != address(0), 'Polygon endpoint can not be 0');

    address polAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      if (config.chainId == TestNetChainIds.ETHEREUM_GOERLI) {
        polAdapter = address(
          new PolygonAdapterGoerli(crossChainController, polConfig.endpoint, trustedRemotes)
        );
      } else if (config.chainId == TestNetChainIds.POLYGON_MUMBAI) {
        polAdapter = address(
          new PolygonAdapterMumbai(crossChainController, polConfig.endpoint, trustedRemotes)
        );
      }
    } else {
      if (config.chainId == ChainIds.ETHEREUM) {
        polAdapter = address(
          new PolygonAdapterEthereum(crossChainController, polConfig.endpoint, trustedRemotes)
        );
      } else if (config.chainId == ChainIds.POLYGON) {
        polAdapter = address(
          new PolygonAdapterPolygon(crossChainController, polConfig.endpoint, trustedRemotes)
        );
      }
    }

    require(polAdapter != address(0), 'Polygon adapter needs to be deployed');
    currentAddresses.polAdapter = revisionAddresses.polAdapter = polAdapter;
  }
}
