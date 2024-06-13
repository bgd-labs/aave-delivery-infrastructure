// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {AxelarAdapter, IAxelarAdapter, IBaseAdapter} from '../../src/contracts/adapters/axelar/AxelarAdapter.sol';
import {AxelarAdapterTestnet} from '../contract_extensions/AxelarAdapter.sol';
import './BaseAdapterScript.sol';

library AxelarAdapterDeploymentHelper {
  struct AxelarAdapterArgs {
    BaseAdapterArgs baseArgs;
    address axelarGateway;
    address axelarGasService;
  }

  function getAdapterCode(
    AxelarAdapterArgs memory axelarArgs
  ) internal pure returns (bytes memory) {
    bytes memory creationCode = axelarArgs.baseArgs.isTestnet
      ? type(AxelarAdapterTestnet).creationCode
      : type(AxelarAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          IAxelarAdapter.AxelarAdapterArgs({
            crossChainController: axelarArgs.baseArgs.crossChainController,
            providerGasLimit: axelarArgs.baseArgs.providerGasLimit,
            trustedRemotes: axelarArgs.baseArgs.trustedRemotes,
            gateway: axelarArgs.axelarGateway,
            gasService: axelarArgs.axelarGasService
          })
        )
      );
  }
}

abstract contract BaseDeployAxelarAdapter is BaseAdapterScript {
  function AXELAR_GATEWAY() public view virtual returns (address);

  function AXELAR_GAS_SERVICE() public view virtual returns (address);

  function _getAdapterByteCode(
    BaseAdapterArgs memory baseArgs
  ) internal view override returns (bytes memory) {
    require(AXELAR_GATEWAY() != address(0), 'Invalid Axelar Gateway');
    require(AXELAR_GAS_SERVICE() != address(0), 'Invalid Axelar Gas Service');

    return
      AxelarAdapterDeploymentHelper.getAdapterCode(
        AxelarAdapterDeploymentHelper.AxelarAdapterArgs({
          baseArgs: baseArgs,
          axelarGateway: AXELAR_GATEWAY(),
          axelarGasService: AXELAR_GAS_SERVICE()
        })
      );
  }
}
