// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.0;

import {CalldataBytesLib} from './CalldataBytesLib.sol';

library ExecutorOptions {
  using CalldataBytesLib for bytes;

  uint8 internal constant WORKER_ID = 1;

  uint8 internal constant OPTION_TYPE_LZRECEIVE = 1;

  function encodeLzReceiveOption(
    uint128 _gas,
    uint128 _value
  ) internal pure returns (bytes memory) {
    return _value == 0 ? abi.encodePacked(_gas) : abi.encodePacked(_gas, _value);
  }
}
