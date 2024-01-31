// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

contract SetCCRAdapters is DeploymentConfigurationBaseScript {
  ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] bridgeAdapterConfig;

  function getChainIdsForAdapter(
    Adapters adapter,
    Connections memory rConfig
  ) internal pure returns (uint256[] memory) {
    uint256 counter;
    uint256[] memory chainIds = rConfig.chainIds;
    for (uint256 i = 0; i < chainIds.length; i++) {
      Adapters[] memory adapterIds = _getAdapterIds(chainIds[i], rConfig);
      for (uint256 j = 0; j < adapterIds.length; j++) {
        if (adapterIds[j] == adapter) {
          counter++;
        }
      }
    }
    uint256[] memory chains = new uint256[](counter);
    uint256 chainCounter;
    for (uint256 k = 0; k < chainIds.length; k++) {
      Adapters[] memory adapterIds = _getAdapterIds(chainIds[k], rConfig);
      for (uint256 j = 0; j < adapterIds.length; j++) {
        if (adapterIds[j] == adapter) {
          chains[chainCounter] = chainIds[k];
          chainCounter++;
        }
      }
    }

    return chains;
  }

  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    Connections memory rConfig = config.receiverConnections;

    uint256[] memory chainIds = rConfig.chainIds;
    for (uint256 i = 0; i < chainIds.length; i++) {
      Adapters[] memory adapterIds = _getAdapterIds(chainIds[i], rConfig);

      for (uint256 j = 0; j < adapterIds.length; j++) {
        require(adapterIds[j] > Adapters.Null_Adapter, 'Adapter id can not be 0');
        address currentChainAdapter = getAdapter(
          adapterIds[j],
          currentAddresses,
          revisionAddresses
        );
        require(currentChainAdapter != address(0), 'Current chain adapter can not be 0');

        uint256[] memory chainIdsForAdapter = getChainIdsForAdapter(adapterIds[j], rConfig);
        require(
          chainIdsForAdapter.length > 0,
          'Receiver Adapters must be receiving from at least one chain'
        );

        bridgeAdapterConfig.push(
          ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
            bridgeAdapter: currentChainAdapter,
            chainIds: chainIdsForAdapter
          })
        );
      }
    }

    address crossChainController = _getCrossChainController(
      currentAddresses,
      revisionAddresses,
      config.chainId
    );
    require(crossChainController != address(0), 'CCC can not be 0 when setting receiver adapters');
    require(bridgeAdapterConfig.length > 0, 'Some receiver adapters are needed');
    ICrossChainReceiver(crossChainController).allowReceiverBridgeAdapters(bridgeAdapterConfig);
  }
}
