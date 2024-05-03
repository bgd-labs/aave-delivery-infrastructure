// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MetisAdapter, IBaseAdapter} from '../../src/contracts/adapters/metis/MetisAdapter.sol';
import {MetisAdapterTestnet} from '../contract_extensions/MetisAdapter.sol';

abstract contract BaseMetisAdapter {
  function _deployAdapter(
    address crossChainController,
    address ovm,
    uint256 providerGasLimit,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes,
    bool isTestnet,
    bytes32 adapterSalt
  ) internal returns (address) {
    if (isTestnet) {
      return
        address(
          new MetisAdapterTestnet{salt: adapterSalt}(
            crossChainController,
            ovm,
            providerGasLimit,
            trustedRemotes
          )
        );
    } else {
      return
        address(
          new MetisAdapter{salt: adapterSalt}(
            crossChainController,
            ovm,
            providerGasLimit,
            trustedRemotes
          )
        );
    }
  }
}
