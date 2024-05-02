// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter, IBaseAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import {ArbitrumAdapterTestnet} from '../contract_extensions/ArbitrumAdapter.sol';

contract BaseArbAdapter {
  function _deployAdapter(
    address crossChainController,
    address inbox,
    address destinationCCC,
    uint256 providerGasLimit,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes,
    bool isTestnet,
    bytes32 adapterSalt
  ) internal returns (address) {
    if (isTestnet) {
      return
        address(
          new ArbitrumAdapterTestnet{salt: adapterSalt}(
            crossChainController,
            inbox,
            destinationCCC,
            providerGasLimit,
            trustedRemotes
          )
        );
    } else {
      return
        address(
          new ArbAdapter(
            crossChainController,
            inbox,
            destinationCCC,
            providerGasLimit,
            trustedRemotes
          )
        );
    }
  }
}
