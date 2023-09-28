// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IEmergencyConsumer} from './interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from './interfaces/ICLEmergencyOracle.sol';
import {Errors} from '../libs/Errors.sol';

abstract contract EmergencyConsumer is IEmergencyConsumer {
  address internal _chainlinkEmergencyOracle;

  uint256 internal _emergencyCount;

  /// @dev modifier that checks if the oracle emergency is greater than the last resolved one, and if so
  ///      lets execution pass
  modifier onlyInEmergency() {
    (, int256 answer, , , ) = ICLEmergencyOracle(_chainlinkEmergencyOracle).latestRoundData();
    // if there was multiple emergency actions set, we will resolve all of them at once
    require(answer > 0 && uint256(answer) > _emergencyCount, Errors.NOT_IN_EMERGENCY);
    _emergencyCount = uint256(answer);
    _;

    emit EmergencySolved(uint256(answer));
  }

  /**
   * @param chainlinkEmergencyOracle address of the new chainlink emergency mode oracle
   */
  constructor(address chainlinkEmergencyOracle) {
    _updateCLEmergencyOracle(chainlinkEmergencyOracle);
  }

  /// @dev This method is made virtual as it is expected to have access control, but this way it is delegated to implementation.
  function _validateEmergencyAdmin() internal virtual;

  /// @inheritdoc IEmergencyConsumer
  function updateCLEmergencyOracle(address chainlinkEmergencyOracle) external {
    _validateEmergencyAdmin();
    _updateCLEmergencyOracle(chainlinkEmergencyOracle);
  }

  /// @inheritdoc IEmergencyConsumer
  function getChainlinkEmergencyOracle() public view returns (address) {
    return _chainlinkEmergencyOracle;
  }

  /// @inheritdoc IEmergencyConsumer
  function getEmergencyCount() public view returns (uint256) {
    return _emergencyCount;
  }

  /**
   * @dev method to update the chainlink emergency oracle
   * @param chainlinkEmergencyOracle address of the new oracle
   */
  function _updateCLEmergencyOracle(address chainlinkEmergencyOracle) internal {
    require(chainlinkEmergencyOracle != address(0), Errors.INVALID_EMERGENCY_ORACLE);
    _chainlinkEmergencyOracle = chainlinkEmergencyOracle;

    emit CLEmergencyOracleUpdated(chainlinkEmergencyOracle);
  }
}
