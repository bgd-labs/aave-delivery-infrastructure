// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Math {
  /**
   * @notice method to get a pseudo random number from block timestamp, block number, prevrandao and an entropy value
   * @param entropy number assigned by method caller to give certain entropy to the pseudo random generation
   * @return a pseudo random number
   */
  function getPseudoRandom(uint256 entropy) internal view returns (uint256) {
    return
      uint256(
        keccak256(abi.encodePacked(block.number - 1, block.timestamp, block.prevrandao, entropy))
      );
  }
}
