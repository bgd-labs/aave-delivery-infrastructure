// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title The interface of the zkSync Bridgehub contract that provides interfaces for L1 <-> L2 interaction.
/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
interface IBridgehub {
  struct L2TransactionRequestDirect {
    uint256 chainId;
    uint256 mintValue;
    address l2Contract;
    uint256 l2Value;
    bytes l2Calldata;
    uint256 l2GasLimit;
    uint256 l2GasPerPubdataByteLimit;
    bytes[] factoryDeps;
    address refundRecipient;
  }

  function requestL2TransactionDirect(
    L2TransactionRequestDirect calldata _request
  ) external payable returns (bytes32 canonicalTxHash);

  /// @notice Estimates the cost in Ether of requesting execution of an L2 transaction from L1
  /// @param _gasPrice expected L1 gas price at which the user requests the transaction execution
  /// @param _l2GasLimit Maximum amount of L2 gas that transaction can consume during execution on L2
  /// @param _l2GasPerPubdataByteLimit The maximum amount of L2 gas that the operator may charge the user for a single byte of pubdata.
  /// @return The estimated ETH spent on L2 gas for the transaction
  function l2TransactionBaseCost(
    uint256 _chainId,
    uint256 _gasPrice,
    uint256 _l2GasLimit,
    uint256 _l2GasPerPubdataByteLimit
  ) external view returns (uint256);
}
