// SPDX-License-Identifier: MIT OR Apache-2.0
// Copied from commit: https://github.com/hyperlane-xyz/hyperlane-monorepo/commit/e8d90775f777b59830c3591c3c0b8827234f8dda
pragma solidity >=0.6.11;

library TypeCasts {
  // alignment preserving cast
  function addressToBytes32(address _addr) internal pure returns (bytes32) {
    return bytes32(uint256(uint160(_addr)));
  }

  // alignment preserving cast
  function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
    return address(uint160(uint256(_buf)));
  }
}
