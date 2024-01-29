// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

contract SetCCRConfirmations is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    Confirmations memory cConfig = config.ccc.confirmations;

    uint256[] memory chainIds = cConfig.chainIds;

    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationsInput = new ICrossChainReceiver.ConfirmationInput[](chainIds.length);

    for (uint256 i = 0; i < chainIds.length; i++) {
      uint8 confirmations = _getConfirmations(chainIds[i], cConfig);

      require(confirmations > 0, 'Required confirmations can not be 0');

      confirmationsInput[i] = ICrossChainReceiver.ConfirmationInput({
        chainId: chainIds[i],
        requiredConfirmations: confirmations
      });
    }

    address crossChainController = _getCrossChainController(
      currentAddresses,
      revisionAddresses,
      config.chainId
    );
    require(crossChainController != address(0), 'CCC can not be 0 when setting confirmations');

    require(confirmationsInput.length > 0, 'Must have at least one confirmation to set');

    ICrossChainReceiver(crossChainController).updateConfirmations(confirmationsInput);

    // TODO: provably makes sense to also save configuration on the revision and current jsons
    // to keep track of the changes
  }
}
