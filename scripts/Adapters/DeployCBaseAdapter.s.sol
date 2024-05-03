// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CBaseAdapter} from '../../src/contracts/adapters/cBase/CBaseAdapter.sol';
import {CBaseAdapterTestnet} from '../contract_extensions/CBAdapter.sol';
import {IBaseAdapterScript} from './IBaseAdapterScript.sol';

abstract contract BaseCBAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address ovm
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new CBaseAdapterTestnet{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new CBaseAdapter{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
