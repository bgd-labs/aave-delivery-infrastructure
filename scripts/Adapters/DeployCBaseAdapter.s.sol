// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CBaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/cBase/CBaseAdapter.sol';
import './BaseAdapterScript.sol';
import {CBaseAdapterTestnet} from '../contract_extensions/CBAdapter.sol';

abstract contract BaseCBAdapter is BaseAdapterScript {
  function OVM() public view virtual returns (address);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(OVM() != address(0), 'Invalid OVM address');

    if (isTestnet()) {
      addresses.baseAdapter = address(
        new CBaseAdapterTestnet(
          addresses.crossChainController,
          OVM(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      addresses.baseAdapter = address(
        new CBaseAdapter(
          addresses.crossChainController,
          OVM(),
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
  }
}
