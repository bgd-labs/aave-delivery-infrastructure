// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import {ArbitrumAdapterTestnet} from '../contract_extensions/ArbitrumAdapter.sol';
import {IBaseAdapterScript} from './IBaseAdapterScript.sol';

contract BaseArbAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address inbox,
    address destinationCCC
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new ArbitrumAdapterTestnet{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            inbox,
            destinationCCC,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new ArbAdapter{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            inbox,
            destinationCCC,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
