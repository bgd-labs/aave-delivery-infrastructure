// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../interfaces/ICrossChainForwarder.sol';

/**
 * @title IReinitialize
 * @author BGD Labs
 * @notice interface containing re initialization method
 */
interface IReinitialize {
  /**
   * @notice method called to re initialize the proxy
   * @param optimalBandwidthByChain array of optimal numbers of bridge adapters to use to send a message to receiver chain
   */
  function initializeRevision(
    ICrossChainForwarder.OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) external;
}
