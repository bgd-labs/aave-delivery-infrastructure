// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEmergencyConsumer {
  /**
   * @dev emitted when chainlink emergency oracle gets updated
   * @param chainlinkEmergencyOracle address of the new oracle
   */
  event CLEmergencyOracleUpdated(address indexed chainlinkEmergencyOracle);

  /**
   * @dev emitted when the emergency is solved
   * @param emergencyCount number of emergencies solved. Used to check if a new emergency is active.
   */
  event EmergencySolved(uint256 emergencyCount);

  /**
   * @notice method that returns the last emergency solved
   * @return the current emergency count
   */
  function getEmergencyCount() external view returns (uint256);

  /**
   * @notice method that returns the address of the current chainlink emergency oracle
   * @return the Chainlink emergency oracle address
   */
  function getChainlinkEmergencyOracle() external view returns (address);

  /**
   * @dev method to update the chainlink emergency mode address.
   *      This method is made virtual as it is expected to have access control, but this way it is delegated to implementation.
   *      It should call _updateCLEmergencyOracle when implemented
   * @param chainlinkEmergencyOracle address of the new chainlink emergency mode oracle
   */
  function updateCLEmergencyOracle(address chainlinkEmergencyOracle) external;
}
