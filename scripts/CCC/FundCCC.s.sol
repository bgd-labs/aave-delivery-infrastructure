// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';

contract FundCrossChainController is BaseScript {
  function getAmountToFund() public view virtual returns (uint256) {
    return 500000000000000000;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    (bool success, ) = addresses.crossChainController.call{value: getAmountToFund()}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }
}
