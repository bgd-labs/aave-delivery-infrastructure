// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CCIPAdapter, ICCIPAdapter, IBaseAdapter} from '../../src/contracts/adapters/ccip/CCIPAdapter.sol';
import {CCIPAdapterTestnet} from '../contract_extensions/CCIPAdapter.sol';

// configs can be found here: https://docs.chain.link/ccip/supported-networks/v1_2_0/mainnet#bnb-mainnet
abstract contract BaseCCIPAdapter {
  function _deployAdapter(
    address crossChainController,
    address ccipRouter,
    address linkToken,
    address destinationCCC,
    uint256 providerGasLimit,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes,
    bool isTestnet,
    bytes32 adapterSalt
  ) internal returns (address) {
    if (isTestnet) {
      return
        address(
          new CCIPAdapterTestnet{salt: adapterSalt}(
            crossChainController,
            ccipRouter,
            providerGasLimit,
            trustedRemotes,
            linkToken
          )
        );
    } else {
      return
        address(
          new CCIPAdapter{salt: adapterSalt}(
            crossChainController,
            ccipRouter,
            providerGasLimit,
            trustedRemotes,
            linkToken
          )
        );
    }
  }
}
