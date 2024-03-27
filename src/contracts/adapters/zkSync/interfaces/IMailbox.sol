// SPDX-License-Identifier: MIT
// Modified from commit: https://github.com/matter-labs/era-contracts/commit/e77971dba8f589b625e72e69dd7e33ccbe697cc0

pragma solidity ^0.8.0;

/// @title The interface of the zkSync Mailbox contract that provides interfaces for L1 <-> L2 interaction.
/// @author Matter Labs
/// @custom:security-contact security@matterlabs.dev
interface IMailbox {
  /// @notice Request execution of L2 transaction from L1.
  /// @param _contractL2 The L2 receiver address
  /// @param _l2Value `msg.value` of L2 transaction
  /// @param _calldata The input of the L2 transaction
  /// @param _l2GasLimit Maximum amount of L2 gas that transaction can consume during execution on L2
  /// @param _l2GasPerPubdataByteLimit The maximum amount L2 gas that the operator may charge the user for single byte of pubdata.
  /// @param _factoryDeps An array of L2 bytecodes that will be marked as known on L2
  /// @param _refundRecipient The address on L2 that will receive the refund for the transaction.
  /// @dev If the L2 deposit finalization transaction fails, the `_refundRecipient` will receive the `_l2Value`.
  /// Please note, the contract may change the refund recipient's address to eliminate sending funds to addresses out of control.
  /// - If `_refundRecipient` is a contract on L1, the refund will be sent to the aliased `_refundRecipient`.
  /// - If `_refundRecipient` is set to `address(0)` and the sender has NO deployed bytecode on L1, the refund will be sent to the `msg.sender` address.
  /// - If `_refundRecipient` is set to `address(0)` and the sender has deployed bytecode on L1, the refund will be sent to the aliased `msg.sender` address.
  /// @dev The address aliasing of L1 contracts as refund recipient on L2 is necessary to guarantee that the funds are controllable,
  /// since address aliasing to the from address for the L2 tx will be applied if the L1 `msg.sender` is a contract.
  /// Without address aliasing for L1 contracts as refund recipients they would not be able to make proper L2 tx requests
  /// through the Mailbox to use or withdraw the funds from L2, and the funds would be lost.
  /// @return canonicalTxHash The hash of the requested L2 transaction. This hash can be used to follow the transaction status
  function requestL2Transaction(
    address _contractL2,
    uint256 _l2Value,
    bytes calldata _calldata,
    uint256 _l2GasLimit,
    uint256 _l2GasPerPubdataByteLimit,
    bytes[] calldata _factoryDeps,
    address _refundRecipient
  ) external payable returns (bytes32 canonicalTxHash);

  /// @notice Estimates the cost in Ether of requesting execution of an L2 transaction from L1
  /// @param _gasPrice expected L1 gas price at which the user requests the transaction execution
  /// @param _l2GasLimit Maximum amount of L2 gas that transaction can consume during execution on L2
  /// @param _l2GasPerPubdataByteLimit The maximum amount of L2 gas that the operator may charge the user for a single byte of pubdata.
  /// @return The estimated ETH spent on L2 gas for the transaction
  function l2TransactionBaseCost(
    uint256 _gasPrice,
    uint256 _l2GasLimit,
    uint256 _l2GasPerPubdataByteLimit
  ) external view returns (uint256);
}
