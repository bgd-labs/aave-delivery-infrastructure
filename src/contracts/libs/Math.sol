// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Math {
  /**
   * @notice
   * @param
   * @return
   */
  function randMod(uint256 modulus) internal view returns (uint256) {
    return uint256(block.blockhash(block.number)) % modulus;
  }
}
