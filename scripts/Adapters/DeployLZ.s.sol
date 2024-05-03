// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LayerZeroAdapter, ILayerZeroAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {LayerZeroAdapterTestnet} from '../contract_extensions/LayerZeroAdapter.sol';
import {IBaseAdapterScript} from './IBaseAdapterScript.sol';

abstract contract BaseLZAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address lzEndpoint
  ) internal returns (address) {
    address lzAdapter;
    if (baseArgs.isTestnet) {
      return
        address(
          new LayerZeroAdapterTestnet{salt: baseArgs.adapterSalt}(
            lzEndpoint,
            baseArgs.crossChainController,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new LayerZeroAdapter{salt: baseArgs.adapterSalt}(
            lzEndpoint,
            baseArgs.crossChainController,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
