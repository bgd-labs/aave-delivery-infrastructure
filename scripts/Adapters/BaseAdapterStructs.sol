// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

library BaseAdapterStructs {
  struct BaseAdapterArgs {
    address crossChainController;
    uint256 providerGasLimit;
    IBaseAdapter.TrustedRemotesConfig[] trustedRemotes;
    bytes32 adapterSalt;
    bool isTestnet;
  }
}
