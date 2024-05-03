// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {HyperLaneAdapter, IHyperLaneAdapter} from '../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';
import {IBaseAdapterScript} from './IBaseAdapterScript.sol';

abstract contract BaseHLAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address hlMailBox
  ) internal returns (address) {
    return
      address(
        new HyperLaneAdapter{salt: baseArgs.adapterSalt}(
          baseArgs.crossChainController,
          hlMailBox,
          baseArgs.providerGasLimit,
          baseArgs.trustedRemotes
        )
      );
  }
}
