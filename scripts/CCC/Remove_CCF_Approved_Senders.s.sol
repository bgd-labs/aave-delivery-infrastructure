// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

contract RemoveCCFApprovedSenders is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    address[] memory sendersToRemove = config.ccc.sendersToRemove;
    address crossChainController = _getCrossChainController(
      currentAddresses,
      revisionAddresses,
      config.chainId
    );
    require(crossChainController != address(0), 'CCC can not be 0 when removing senders');

    require(sendersToRemove.length > 0, 'There must be senders to remove');

    ICrossChainForwarder(crossChainController).removeSenders(sendersToRemove);
  }
}
