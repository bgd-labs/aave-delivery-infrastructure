// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IGnosisChainAdapter
 * @author BGD Labs
 * @notice interface containing the receiving function for the GnosisChainAdapter.
 */
interface IGnosisChainAdapter {
  /**
   * @notice method called by the Arbitrary Message Bridge on Gnosis Chain with the bridged message
   * @param message bytes containing the bridged information
   */
  function receiveMessage(bytes calldata message) external;
}
