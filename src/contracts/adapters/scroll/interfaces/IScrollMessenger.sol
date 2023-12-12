// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import {IL1MessageQueue} from './IL1MessageQueue.sol';

interface IScrollMessenger {
  function messageQueue() external view returns (IL1MessageQueue);

  /*****************************
   * Public Mutating Functions *
   *****************************/

  /// @notice Send cross chain message from L1 to L2 or L2 to L1.
  /// @param target The address of account who receive the message.
  /// @param value The amount of ether passed when call target contract.
  /// @param message The content of the message.
  /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
  function sendMessage(
    address target,
    uint256 value,
    bytes calldata message,
    uint256 gasLimit
  ) external payable;

  /// @notice Send cross chain message from L1 to L2 or L2 to L1.
  /// @param target The address of account who receive the message.
  /// @param value The amount of ether passed when call target contract.
  /// @param message The content of the message.
  /// @param gasLimit Gas limit required to complete the message relay on corresponding chain.
  /// @param refundAddress The address of account who will receive the refunded fee.
  function sendMessage(
    address target,
    uint256 value,
    bytes calldata message,
    uint256 gasLimit,
    address refundAddress
  ) external payable;
}
