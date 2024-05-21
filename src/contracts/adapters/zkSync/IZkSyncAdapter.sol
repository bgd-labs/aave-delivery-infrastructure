// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMailbox} from './interfaces/IMailbox.sol';
import {IClOracle} from './interfaces/IClOracle.sol';

/**
 * @title IZkSyncAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the ZkSync bridge adapter
 */
interface IZkSyncAdapter {
  /**
   * @notice method to get the MAILBOX address
   * @return address of the MAILBOX
   */
  function MAILBOX() external view returns (IMailbox);

  /**
   * @notice method to get the required l1 to l2 gas per pubdata.
   * @return pubdata gas limit
   * @dev constant defined by zksync network. Should not change frequently
   */
  function REQUIRED_L1_TO_L2_GAS_PER_PUBDATA_LIMIT() external view returns (uint256);

  /**
   * @notice method to get the refund address on l2
   * @return address to refund excess gas
   */
  function REFUND_ADDRESS_L2() external view returns (address);

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

  /**
   * @notice method called by ZkSync with the bridged message
   * @param message bytes containing the bridged information
   */
  function receiveMessage(bytes calldata message) external;
}
