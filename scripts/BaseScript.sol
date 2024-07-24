// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds, TestNetChainIds} from 'aave-helpers/ChainIds.sol';

abstract contract BaseScript {
  function TRANSACTION_NETWORK() internal view virtual returns (uint256);

  // Should only implement as:
  // return Create2Utils.create2Deploy(keccak256(abi.encode(salt)), byteCode);
  function _deployByteCode(
    bytes memory byteCode,
    string memory salt
  ) internal virtual returns (address);

  // Should only implement as:
  // return Create2Utils.computeCreate2Address(salt, adapterCode);
  function _computeByteCodeAddress(
    bytes memory byteCode,
    string memory salt
  ) internal virtual returns (address);
}
