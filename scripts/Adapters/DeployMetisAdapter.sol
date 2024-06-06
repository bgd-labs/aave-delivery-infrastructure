// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MetisAdapter, IBaseAdapter} from '../../src/contracts/adapters/metis/MetisAdapter.sol';
import './BaseAdapterScript.sol';
import {MetisAdapterTestnet} from '../contract_extensions/MetisAdapter.sol';

library MetisAdapterDeploymentHelper {
  struct MetisAdapterArgs {
    BaseAdapterArgs baseArgs;
    address ovm;
  }

  function getAdapterCode(MetisAdapterArgs memory metisArgs) internal pure returns (bytes memory) {
    bytes memory creationCode = metisArgs.baseArgs.isTestnet
      ? type(MetisAdapterTestnet).creationCode
      : type(MetisAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          metisArgs.baseArgs.crossChainController,
          metisArgs.ovm,
          metisArgs.baseArgs.providerGasLimit,
          metisArgs.baseArgs.trustedRemotes
        )
      );
  }
}

abstract contract BaseMetisAdapter is BaseAdapterScript {
  function OVM() internal view virtual returns (address);

  function PROVIDER_GAS_LIMIT() internal view virtual override returns (uint256) {
    return 150_000;
  }

  function _getAdapterByteCode(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (bytes memory) {
    require(currentNetworkCCC != address(0), 'CCC needs to be deployed');
    require(OVM() != address(0), 'Invalid OVM');

    MetisAdapterDeploymentHelper.MetisAdapterArgs
      memory constructorArgs = MetisAdapterDeploymentHelper.MetisAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: currentNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        ovm: OVM()
      });

    return MetisAdapterDeploymentHelper.getAdapterCode(constructorArgs);
  }
}
