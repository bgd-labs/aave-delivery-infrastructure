// SPDX-License-Identifier: LZBL-1.2
// Modified from commit: https://github.com/LayerZero-Labs/LayerZero-v2/commit/982c549236622c6bb9eaa6c65afcf1e0e559b624
pragma solidity ^0.8.0;

library ExecutorOptions {
  uint8 internal constant WORKER_ID = 1;

  uint8 internal constant OPTION_TYPE_LZRECEIVE = 1;

  function encodeLzReceiveOption(
    uint128 _gas,
    uint128 _value
  ) internal pure returns (bytes memory) {
    return _value == 0 ? abi.encodePacked(_gas) : abi.encodePacked(_gas, _value);
  }
}
