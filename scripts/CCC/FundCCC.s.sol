// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';

contract FundCrossChainController is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    uint256 amountToFund = config.ccc.ethFunds;
    require(amountToFund > 0, 'Must have some amount to fund');

    address crossChainController = _getCrossChainController(
      currentAddresses,
      revisionAddresses,
      config.chainId
    );
    require(crossChainController != address(0), 'CCC can not be 0 when funding');

    (bool success, ) = crossChainController.call{value: amountToFund}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAILED');
  }
}
