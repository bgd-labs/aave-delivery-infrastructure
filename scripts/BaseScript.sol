// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds, TestNetChainIds} from 'aave-helpers/ChainIds.sol';
import {Create2Utils} from 'aave-helpers/ScriptUtils.sol';

abstract contract BaseScript {
  function TRANSACTION_NETWORK() internal view virtual returns (uint256);

  function SALT() internal view virtual returns (string memory) {
    return 'Aave Deliviery Infrastructure';
  }

  function _deployByteCode(bytes memory byteCode) internal virtual returns (address) {
    return Create2Utils.create2Deploy(keccak256(abi.encode(SALT())), byteCode);
  }
}
