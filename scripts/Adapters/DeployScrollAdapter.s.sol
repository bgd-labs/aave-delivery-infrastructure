// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ScrollAdapter} from '../../src/contracts/adapters/scroll/ScrollAdapter.sol';
import {ScrollAdapterTestnet} from '../contract_extensions/ScrollAdapter.sol';
import {IBaseAdapterScript} from './BaseAdapterStructs.sol';

abstract contract BaseScrollAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address ovm
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new ScrollAdapterTestnet{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new ScrollAdapter{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
