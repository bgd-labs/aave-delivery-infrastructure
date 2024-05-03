// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WormholeAdapter, IWormholeAdapter} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import {WormholeAdapterTestnet} from '../contract_extensions/WormholeAdapter.sol';
import {IBaseAdapterScript} from './IBaseAdapterScript.sol';

abstract contract BaseWormholeAdapter is IBaseAdapterScript {
  /// @dev for now we will need to deploy one adapter for every path (one remote network) because of the refunding on
  /// destination ccc
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address wormholeRelayer,
    address destinationCCC
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new WormholeAdapterTestnet{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            wormholeRelayer,
            destinationCCC,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new WormholeAdapter{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            wormholeRelayer,
            destinationCCC,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
