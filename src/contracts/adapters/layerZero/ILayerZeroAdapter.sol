// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILayerZeroAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the LayerZero bridge adapter
 */
interface ILayerZeroAdapter {
  /**
   * @notice returns the layer zero version used
   * @return LayerZero version
   */
  function VERSION() external view returns (uint16);
}
