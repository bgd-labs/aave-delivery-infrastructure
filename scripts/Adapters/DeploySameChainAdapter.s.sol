// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SameChainAdapter} from '../../src/contracts/adapters/sameChain/SameChainAdapter.sol';

abstract contract BaseSameChainAdapter {
  function _deployAdapter(bytes32 adapterSalt) internal returns (address) {
    return address(new SameChainAdapter{salt: adapterSalt}());
  }
}
