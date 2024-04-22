// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Math {
  /**
   * @notice method to get a random number from block timestamp, and in a range determined by modulus
   * @param modulus upper bound of the range to get the random number
   * @return a random number
   */
  function randMod(uint256 modulus) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.number - 1, block.timestamp))) % modulus;
  }
}
