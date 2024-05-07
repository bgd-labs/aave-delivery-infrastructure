// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PolygonAdapterEthereum} from '../../src/contracts/adapters/polygon/PolygonAdapterEthereum.sol';
import {PolygonAdapterPolygon} from '../../src/contracts/adapters/polygon/PolygonAdapterPolygon.sol';
import {PolygonAdapterGoerli, PolygonAdapterMumbai} from '../contract_extensions/PolygonAdapterTestnets.sol';
import {IBaseAdapterScript} from './BaseAdapterStructs.sol';

abstract contract BaseEthereumPolygonAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address fxTunnel
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new PolygonAdapterGoerli{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            fxTunnel,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new PolygonAdapterEthereum{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            fxTunnel,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}

abstract contract BasePolygonEthereumAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address fxTunnel
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new PolygonAdapterMumbai{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            fxTunnel,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new PolygonAdapterPolygon{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            fxTunnel,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
