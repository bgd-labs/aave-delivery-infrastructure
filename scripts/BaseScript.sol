// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds, TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {Create2Utils} from 'solidity-utils/contracts/utils/ScriptUtils.sol';

abstract contract BaseScript {
  function TRANSACTION_NETWORK() internal view virtual returns (uint256);

  function _deployByteCode(
    bytes memory byteCode,
    string memory salt
  ) internal virtual returns (address) {
    return Create2Utils.create2Deploy(keccak256(abi.encode(salt)), byteCode);
  }

  function _computeByteCodeAddress(
    bytes memory byteCode,
    string memory salt
  ) internal virtual returns (address) {
    bytes32 encodedSalt = keccak256(abi.encode(salt));
    return Create2Utils.computeCreate2Address(encodedSalt, byteCode);
  }
}
