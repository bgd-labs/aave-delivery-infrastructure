// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IFxTunnel
 * @author BGD Labs
 * @notice Interface for the FxTunnel two-way messaging contracts.
 */
interface IFxTunnel {
  /**
   * @notice Sends a message to the receiver via the connected root or child tunnel.
   * 
   * @param receiver The receiver address on the paired chain.
   * @param message The raw message to send to the receiver on the paired chain.
   */
  function sendMessage(address receiver, bytes memory message) external;
}
