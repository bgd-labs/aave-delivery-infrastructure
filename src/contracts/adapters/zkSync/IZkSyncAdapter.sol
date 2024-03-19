// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IZkSync} from 'era-contracts/interfaces/IZkSync.sol';

/**
 * @title IZkSyncAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the ZkSync bridge adapter
 */
interface IZkSyncAdapter is IZkSync {
  /**
   * @notice method to get the MAILBOX address
   * @return address of the MAILBOX
   */
  function MAILBOX() external view returns (address);

  /**
   * @notice method to know if a destination chain is supported
   * @return flag indicating if the destination chain is supported
   */
  function isDestinationChainIdSupported(uint256 chainId) external view returns (bool);

  /**
   * @notice method to get the origin chain id
   * @return id of the chain where the messages originate.
   * @dev this method is needed as ZkSync does not pass the origin chain
   */
  function getOriginChainId() external view returns (uint256);
}
