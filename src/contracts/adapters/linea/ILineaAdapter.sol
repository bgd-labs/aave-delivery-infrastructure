// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ILineaAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the Linea bridge adapter
 */
interface ILineaAdapter {
  /**
   * @notice method to get the Linea message service address
   * @return address of the Linea message service
   */
  function LINEA_MESSAGE_SERVICE() external view returns (address);

  /**
   * @notice method to know if a destination chain is supported by adapter
   * @return flag indicating if the destination chain is supported by the adapter
   */
  function isDestinationChainIdSupported(uint256 chainId) external view returns (bool);

  /**
   * @notice method called by Linea message service with the bridged message
   * @param message bytes containing the bridged information
   */
  function receiveMessage(bytes memory message) external;

  /**
   * @notice method to get the origin chain id
   * @return id of the chain where the messages originate.
   * @dev this method is needed as Optimism does not pass the origin chain
   */
  function getOriginChainId() external view returns (uint256);
}
