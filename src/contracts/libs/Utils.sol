// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library Utils {
  /**
   * @notice method to get a pseudo random number from previous block number, blockHash of the previous block number and an entropy value
   * @param entropy number assigned by method caller to give certain entropy to the pseudo random generation
   * @return a pseudo random number
   * @dev As this method does not offer real randomness, evaluate appropriately its usage.
   */
  function getPseudoRandom(uint256 entropy) internal view returns (uint256) {
    uint256 blockNumber = block.number - 1;
    return uint256(keccak256(abi.encodePacked(blockNumber, blockhash(blockNumber), entropy)));
  }

  /**
   * @notice method to generate an array of indexes with the specified length [0,1,2,...]
   * @param length number indicating the size of the array to generate
   * @return array of numbers with specified length
   */
  function generateIndexArray(uint256 length) internal pure returns (uint256[] memory) {
    uint256[] memory indexArray = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      indexArray[i] = i;
    }
    return indexArray;
  }

  /**
   * @notice method to shuffle an array of forwarder configurations
   * @param arrayToShuffle array that needs to be shuffled
   * @return shuffled array of forwarder configurations
   */
  function shuffleArray(
    uint256[] memory arrayToShuffle,
    uint256 optimalBandwidth
  ) internal view returns (uint256[] memory) {
    uint256 arrayLength = arrayToShuffle.length;
    for (uint256 i = 0; i < optimalBandwidth; i++) {
      uint256 j = getPseudoRandom(i) % arrayLength;
      uint256 arrayItem = arrayToShuffle[i];
      arrayToShuffle[i] = arrayToShuffle[j];
      arrayToShuffle[j] = arrayItem;
    }
    return arrayToShuffle;
  }
}
