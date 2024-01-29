// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

contract EnableCCFSenderAdapters is DeploymentConfigurationBaseScript {
  ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] bridgeAdaptersToEnable;

  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    Connections memory fdConfig = config.forwarderConnections;

    uint256[] memory chainIds = fdConfig.chainIds;

    for (uint256 i = 0; i < chainIds.length; i++) {
      uint8[] memory adapterIds = _getAdapterIds(chainIds[i], fdConfig);

      for (uint256 j = 0; j < adapterIds.length; j++) {
        require(adapterIds[j] > uint8(Adapters.Null_Adapter), 'Adapter id can not be 0');

        address currentChainAdapter = getAdapter(
          Adapters(adapterIds[j]),
          currentAddresses,
          revisionAddresses
        );
        require(currentChainAdapter != address(0), 'Current chain adapter can not be 0');

        if (adapterIds[j] == uint8(Adapters.Same_Chain)) {
          bridgeAdaptersToEnable.push(
            ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
              currentChainBridgeAdapter: currentChainAdapter,
              destinationBridgeAdapter: currentChainAdapter,
              destinationChainId: config.chainId
            })
          );
        } else {
          // fetch current addresses
          Addresses memory remoteCurrentAddresses = _getCurrentAddressesByChainId(chainIds[i], vm);
          // fetch revision addresses
          Addresses memory remoteRevisionAddresses = _getRevisionAddressesByChainId(
            chainIds[i],
            config.revision,
            vm
          );
          address remoteChainAdapter = getAdapter(
            Adapters(adapterIds[j]),
            remoteCurrentAddresses,
            remoteRevisionAddresses
          );
          require(remoteChainAdapter != address(0), 'Remote chain adapter can not be 0');

          bridgeAdaptersToEnable.push(
            ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
              currentChainBridgeAdapter: currentChainAdapter,
              destinationBridgeAdapter: remoteChainAdapter,
              destinationChainId: chainIds[i]
            })
          );
        }
      }
    }

    address crossChainController = AddressBookMiscHelper.getCrossChainController(config.chainId);
    require(crossChainController != address(0), 'CCC can not be 0 when setting adapters');

    require(bridgeAdaptersToEnable.length > 0, 'Some forwarder adapters are needed');
    ICrossChainForwarder(crossChainController).enableBridgeAdapters(bridgeAdaptersToEnable);
  }
}
