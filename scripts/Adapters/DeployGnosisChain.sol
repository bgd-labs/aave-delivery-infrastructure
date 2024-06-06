// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {GnosisChainAdapter} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';
import {BaseAdapterScript, IBaseAdapter} from './BaseAdapterScript.sol';

library GnosisAdapterDeploymentHelper {
  struct GnosisAdapterArgs {
    BaseAdapterArgs baseArgs;
    address ambBridge;
  }

  function getAdapterCode(
    GnosisAdapterArgs memory gnosisArgs
  ) internal pure returns (bytes memory) {
    bytes memory creationCode = type(GnosisChainAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          gnosisArgs.baseArgs.crossChainController,
          gnosisArgs.ambBridge,
          gnosisArgs.baseArgs.providerGasLimit,
          gnosisArgs.baseArgs.trustedRemotes
        )
      );
  }
}

abstract contract BaseGnosisChainAdapter is BaseAdapterScript {
  function GNOSIS_AMB_BRIDGE() internal pure virtual returns (address);

  function _getAdapterByteCode(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (bytes memory) {
    require(currentNetworkCCC != address(0), 'CCC needs to be deployed');
    require(GNOSIS_AMB_BRIDGE() != address(0), 'Invalid AMB BRIDGE Router');

    GnosisAdapterDeploymentHelper.GnosisAdapterArgs
      memory constructorArgs = GnosisAdapterDeploymentHelper.GnosisAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: currentNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        ambBridge: GNOSIS_AMB_BRIDGE()
      });

    return GnosisAdapterDeploymentHelper.getAdapterCode(constructorArgs);
  }
}
