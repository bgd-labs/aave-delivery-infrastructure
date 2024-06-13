// SPDX-License-Identifier: MIT
// Modified from commit https://github.com/axelarnetwork/axelar-gmp-sdk-solidity/commit/269a8980e12a9a0b81da59b32f98c3c41024ea4e
pragma solidity ^0.8.0;

/**
 * @title IAxelarGasService Interface
 * @notice This is an interface for the AxelarGasService contract which manages gas payments
 * and refunds for cross-chain communication on the Axelar network.
 */
interface IAxelarGasService {
  /**
   * @notice Pay for gas for any type of contract execution on a destination chain.
   * @dev This function is called on the source chain before calling the gateway to execute a remote contract.
   * @dev If estimateOnChain is true, the function will estimate the gas cost and revert if the payment is insufficient.
   * @param sender The address making the payment
   * @param destinationChain The target chain where the contract call will be made
   * @param destinationAddress The target address on the destination chain
   * @param payload Data payload for the contract call
   * @param executionGasLimit The gas limit for the contract call
   * @param estimateOnChain Flag to enable on-chain gas estimation
   * @param refundAddress The address where refunds, if any, should be sent
   * @param params Additional parameters for gas payment. This can be left empty for normal contract call payments.
   */
  function payGas(
    address sender,
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    uint256 executionGasLimit,
    bool estimateOnChain,
    address refundAddress,
    bytes calldata params
  ) external payable;

  /**
   * @notice Estimates the gas fee for a cross-chain contract call.
   * @param destinationChain Axelar registered name of the destination chain
   * @param destinationAddress Destination contract address being called
   * @param executionGasLimit The gas limit to be used for the destination contract execution,
   *        e.g. pass in 200k if your app consumes needs upto 200k for this contract call
   * @param params Additional parameters for the gas estimation
   * @return gasEstimate The cross-chain gas estimate, in terms of source chain's native gas token that should be forwarded to the gas service.
   */
  function estimateGasFee(
    string calldata destinationChain,
    string calldata destinationAddress,
    bytes calldata payload,
    uint256 executionGasLimit,
    bytes calldata params
  ) external view returns (uint256 gasEstimate);
}
