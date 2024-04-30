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
   */
  function initializeRevision(
    ICrossChainForwarder.RequiredConfirmationsByReceiverChain[]
      memory requiredConfirmationsByReceiverChain
  ) external;
}
