// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {GnosisChainAdapter, IBaseAdapter} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';

contract DeployGnosisChainAdapter is BaseAdapterScript {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.gnosisAdapter.remoteNetworks;
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

    EndpointAdapterInfo memory gnosisConfig = config.adapters.gnosisAdapter;
    require(gnosisConfig.endpoint != address(0), 'Gnosis amb bridge can not be 0');

    address gnosisAdapter = address(
      new GnosisChainAdapter(crossChainController, gnosisConfig.endpoint, trustedRemotes)
    );
    currentAddresses.gnosisAdapter = revisionAddresses.gnosisAdapter = gnosisAdapter;
  }
}

//address constant AMB_BRIDGE_ETHEREUM = 0x4C36d2919e407f0Cc2Ee3c993ccF8ac26d9CE64e;
//address constant AMB_BRIDGE_GOERLI = 0x87A19d769D875964E9Cd41dDBfc397B2543764E6;
//address constant AMB_BRIDGE_GNOSIS = 0x75Df5AF045d91108662D8080fD1FEFAd6aA0bb59;
//address constant AMB_BRIDGE_CHIADO = 0x99Ca51a3534785ED619f46A79C7Ad65Fa8d85e7a;
