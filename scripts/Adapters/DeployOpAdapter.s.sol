// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {OpAdapter, IOpAdapter} from '../../src/contracts/adapters/optimism/OpAdapter.sol';
import {OptimismAdapterTestnet} from '../contract_extensions/OptimismAdapter.sol';
import {IBaseAdapterScript} from './BaseAdapterStructs.sol';

abstract contract BaseOpAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address ovm
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new OptimismAdapterTestnet{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new OpAdapter{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            ovm,
            baseArgs.providerGasLimit,
            'Optimism native adapter',
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
