// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LayerZeroAdapter, ILayerZeroAdapter, IBaseAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {LayerZeroAdapterTestnet} from '../contract_extensions/LayerZeroAdapter.sol';
import './BaseAdapterScript.sol';

library LZAdapterDeploymentHelper {
  struct LZAdapterArgs {
    BaseAdapterArgs baseArgs;
    address lzEndpoint;
  }

  function getAdapterCode(LZAdapterArgs memory lzArgs) internal pure returns (bytes memory) {
    bytes memory creationCode = lzArgs.baseArgs.isTestnet
      ? type(LayerZeroAdapterTestnet).creationCode
      : type(LayerZeroAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          lzArgs.baseArgs.crossChainController,
          lzArgs.lzEndpoint,
          lzArgs.baseArgs.providerGasLimit,
          lzArgs.baseArgs.trustedRemotes
        )
      );
  }
}

abstract contract BaseLZAdapter is BaseAdapterScript {
  function LZ_ENDPOINT() internal view virtual returns (address);

  function _getAdapterByteCode(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (bytes memory) {
    require(currentNetworkCCC != address(0), 'CCC needs to be deployed');
    require(LZ_ENDPOINT() != address(0), 'Invalid LZ Endpoint');

    LZAdapterDeploymentHelper.LZAdapterArgs memory constructorArgs = LZAdapterDeploymentHelper
      .LZAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: currentNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        ccipRouter: LZ_ENDPOINT()
      });

    return LZAdapterDeploymentHelper.getAdapterCode(constructorArgs);
  }
}
