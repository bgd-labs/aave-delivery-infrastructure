// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import '../BaseScript.sol';

/**
 * @notice This script needs to be implemented from where the senders are known
 */
abstract contract BaseRemoveCCFApprovedSenders is BaseScript {
  function getSendersToRemove() public virtual returns (address[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).removeSenders(getSendersToRemove());
  }
}
