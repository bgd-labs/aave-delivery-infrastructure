// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title IAxelarGasService Interface
 * @notice This is an interface for the AxelarGasService contract which manages gas payments
 * and refunds for cross-chain communication on the Axelar network.
 * @dev This interface inherits IUpgradable
 */
interface IAxelarGasService {
  /**
   * @notice Pay for gas using ERC20 tokens for a contract call on a destination chain.
   * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
   * @param sender The address making the payment
   * @param destinationChain The target chain where the contract call will be made
   * @param destinationAddress The target address on the destination chain
   * @param payload Data payload for the contract call
   * @param gasToken The address of the ERC20 token used to pay for gas
   * @param gasFeeAmount The amount of tokens to pay for gas
   * @param refundAddress The address where refunds, if any, should be sent
   */
  function payGasForContractCall(
    address sender,
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    address gasToken,
    uint256 gasFeeAmount,
    address refundAddress
  ) external;

  /**
   * @notice Pay for gas using native currency for a contract call on a destination chain.
   * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
   * @param sender The address making the payment
   * @param destinationChain The target chain where the contract call will be made
   * @param destinationAddress The target address on the destination chain
   * @param payload Data payload for the contract call
   * @param refundAddress The address where refunds, if any, should be sent
   */
  function payNativeGasForContractCall(
    address sender,
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    address refundAddress
  ) external payable;

  /**
   * @notice Pay for gas using ERC20 tokens for an express contract call on a destination chain.
   * @dev This function is called on the source chain before calling the gateway to express execute a remote contract.
   * @param sender The address making the payment
   * @param destinationChain The target chain where the contract call will be made
   * @param destinationAddress The target address on the destination chain
   * @param payload Data payload for the contract call
   * @param gasToken The address of the ERC20 token used to pay for gas
   * @param gasFeeAmount The amount of tokens to pay for gas
   * @param refundAddress The address where refunds, if any, should be sent
   */
  function payGasForExpressCall(
    address sender,
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    address gasToken,
    uint256 gasFeeAmount,
    address refundAddress
  ) external;

  /**
   * @notice Pay for gas using native currency for an express contract call on a destination chain.
   * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
   * @param sender The address making the payment
   * @param destinationChain The target chain where the contract call will be made
   * @param destinationAddress The target address on the destination chain
   * @param payload Data payload for the contract call
   * @param refundAddress The address where refunds, if any, should be sent
   */
  function payNativeGasForExpressCall(
    address sender,
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    address refundAddress
  ) external payable;
}
