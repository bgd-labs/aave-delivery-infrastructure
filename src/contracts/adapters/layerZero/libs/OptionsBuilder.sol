// SPDX-License-Identifier: MIT
// Modified from commit: https://github.com/LayerZero-Labs/LayerZero-v2/commit/bf4318b5e88e46400931bb4c1f6aa0343c035a79
pragma solidity ^0.8.0;

import {BytesLib} from './BytesLib.sol';
import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

import {ExecutorOptions} from './ExecutorOptions.sol';

/**
 * @title OptionsBuilder
 * @dev Library for building and encoding various message options.
 */
library OptionsBuilder {
  using SafeCast for uint256;
  using BytesLib for bytes;

  // Constants for options types
  uint16 internal constant TYPE_3 = 3;

  // Custom error message
  error InvalidOptionType(uint16 optionType);

  // Modifier to ensure only options of type 3 are used
  modifier onlyType3(bytes memory _options) {
    if (_options.toUint16(0) != TYPE_3) revert InvalidOptionType(_options.toUint16(0));
    _;
  }

  /**
   * @dev Creates a new options container with type 3.
   * @return options The newly created options container.
   */
  function newOptions() internal pure returns (bytes memory) {
    return abi.encodePacked(TYPE_3);
  }

  /**
   * @dev Adds an executor LZ receive option to the existing options.
   * @param _options The existing options container.
   * @param _gas The gasLimit used on the lzReceive() function in the OApp.
   * @param _value The msg.value passed to the lzReceive() function in the OApp.
   * @return options The updated options container.
   *
   * @dev When multiples of this option are added, they are summed by the executor
   * eg. if (_gas: 200k, and _value: 1 ether) AND (_gas: 100k, _value: 0.5 ether) are sent in an option to the LayerZeroEndpoint,
   * that becomes (300k, 1.5 ether) when the message is executed on the remote lzReceive() function.
   */
  function addExecutorLzReceiveOption(
    bytes memory _options,
    uint128 _gas,
    uint128 _value
  ) internal pure onlyType3(_options) returns (bytes memory) {
    bytes memory option = ExecutorOptions.encodeLzReceiveOption(_gas, _value);
    return addExecutorOption(_options, ExecutorOptions.OPTION_TYPE_LZRECEIVE, option);
  }

  /**
   * @dev Adds an executor option to the existing options.
   * @param _options The existing options container.
   * @param _optionType The type of the executor option.
   * @param _option The encoded data for the executor option.
   * @return options The updated options container.
   */
  function addExecutorOption(
    bytes memory _options,
    uint8 _optionType,
    bytes memory _option
  ) internal pure onlyType3(_options) returns (bytes memory) {
    return
      abi.encodePacked(
        _options,
        ExecutorOptions.WORKER_ID,
        _option.length.toUint16() + 1, // +1 for optionType
        _optionType,
        _option
      );
  }
}
