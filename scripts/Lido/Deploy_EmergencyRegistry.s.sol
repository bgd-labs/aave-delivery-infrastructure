// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';

import {EmergencyRegistry} from '../../src/contracts/emergency/EmergencyRegistry.sol';
import '../BaseScript.sol';

abstract contract BaseDeployEmergencyMode is BaseScript {
  function getOwner() public view virtual returns (address) {
    return address(msg.sender);
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.emergencyRegistry = address(new EmergencyRegistry());
    Ownable(address(addresses.emergencyRegistry)).transferOwnership(getOwner());
  }
}

contract Ethereum_testnet is BaseDeployEmergencyMode {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
