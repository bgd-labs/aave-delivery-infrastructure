// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CBaseAdapter} from '../../src/contracts/adapters/cBase/CBaseAdapter.sol';
import {CBaseAdapterTestnet} from '../contract_extensions/CBAdapter.sol';
import './BaseAdapterStructs.sol';

library BaseCBAdapter {
  struct CBAdapterArgs {
    BaseAdapterStructs.BaseAdapterArgs baseArgs;
    address ovm;
  }

  function getAdapterCode(CBAdapterArgs memory cbArgs) internal pure returns (bytes memory) {
    if (cbArgs.baseArgs.isTestnet) {
      return
        abi.encodePacked(
          type(CBaseAdapterTestnet).creationCode,
          abi.encode(
            cbArgs.baseArgs.crossChainController,
            cbArgs.ovm,
            cbArgs.baseArgs.providerGasLimit,
            cbArgs.baseArgs.trustedRemotes
          )
        );
    } else {
      return
        abi.encodePacked(
          type(CBaseAdapter).creationCode,
          abi.encode(
            cbArgs.baseArgs.crossChainController,
            cbArgs.ovm,
            cbArgs.baseArgs.providerGasLimit,
            cbArgs.baseArgs.trustedRemotes
          )
        );
    }
  }
}
