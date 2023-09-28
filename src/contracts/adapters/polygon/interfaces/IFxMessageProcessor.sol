// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IFxMessageProcessor
 * @author BGD Labs
 * @notice Interface for message processors receiving messages from FxTunnel implementations.
 */
interface IFxMessageProcessor {
  /**
   * @notice Processes a message received from an FxTunnel implementation.
   * @param originSender The original sender on the origin chain, note that this is the caller of the
   *                    FxTunnel on the origin chain, not the origin FxTunnel itself.
   * @param message The message received.
   */
  function processMessage(address originSender, bytes calldata message) external;
}
