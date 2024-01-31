// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {SameChainAdapter} from '../../src/contracts/adapters/sameChain/SameChainAdapter.sol';

contract DeploySameChainAdapter is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    currentAddresses.sameChainAdapter = revisionAddresses.sameChainAdapter = address(
      new SameChainAdapter()
    );
  }
}
