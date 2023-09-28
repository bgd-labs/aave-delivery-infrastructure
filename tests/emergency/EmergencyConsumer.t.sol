// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {EmergencyConsumer} from '../../src/contracts/emergency/EmergencyConsumer.sol';
import {IEmergencyConsumer} from '../../src/contracts/emergency/interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from '../../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';

contract EmergencyConsumerTest is Test, EmergencyConsumer {
  address public constant CL_EMERGENCY_ORACLE = address(1234);

  constructor() EmergencyConsumer(CL_EMERGENCY_ORACLE) {}

  function setUp() public {}

  function _validateEmergencyAdmin() internal override {}

  function emergencyMethod() public onlyInEmergency {}

  function testGetEmergencyCount() public {
    assertEq(getEmergencyCount(), 0);
  }

  function testGetChainlinkEmergencyOracle() public {
    assertEq(getChainlinkEmergencyOracle(), CL_EMERGENCY_ORACLE);
  }

  function testUpdateCLEmergencyOracleInternalWhenAddress0() public {
    vm.expectRevert(bytes(Errors.INVALID_EMERGENCY_ORACLE));
    _updateCLEmergencyOracle(address(0));
  }

  function testUpdateCLEmergencyOracleInternal(address newChainlinkEmergencyOracle) public {
    vm.assume(newChainlinkEmergencyOracle != address(0));
    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated(newChainlinkEmergencyOracle);
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(_chainlinkEmergencyOracle, newChainlinkEmergencyOracle);
  }

  function testEmergency(int256 answer, uint256 emergencyCount) public {
    vm.assume(answer > 0 && uint256(answer) > emergencyCount);

    uint80 roundId = uint80(0);
    uint256 startedAt = 0;
    uint256 updatedAt = 0;
    uint80 answeredInRound = uint80(0);
    _emergencyCount = emergencyCount;

    vm.mockCall(
      address(CL_EMERGENCY_ORACLE),
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
    );
    vm.expectCall(
      address(CL_EMERGENCY_ORACLE),
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector)
    );
    vm.expectEmit(false, false, false, true);
    emit EmergencySolved(uint256(answer));
    emergencyMethod();

    assertEq(_emergencyCount, uint256(answer));
  }

  function testRevertIfNotInEmergency(int256 answer, uint256 emergencyCount) public {
    vm.assume(answer < 0 || emergencyCount >= uint256(answer));

    uint80 roundId = uint80(0);
    uint256 startedAt = 0;
    uint256 updatedAt = 0;
    uint80 answeredInRound = uint80(0);

    _emergencyCount = emergencyCount;

    vm.mockCall(
      address(CL_EMERGENCY_ORACLE),
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
    );
    vm.expectRevert(bytes(Errors.NOT_IN_EMERGENCY));
    this.emergencyMethod();
  }
}
