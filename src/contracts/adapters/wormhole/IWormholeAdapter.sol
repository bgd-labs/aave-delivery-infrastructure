// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IWormholeAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the Wormhole bridge adapter
 */
interface IWormholeAdapter {
  /**
   * @notice method to get the Wormhole relayer address
   * @return address of the Wormhole relayer
   */
  function WORMHOLE_RELAYER() external view returns (address);
}
