// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './DeploymentConfiguration.sol';
import {EmergencyRegistry} from '../src/contracts/emergency/EmergencyRegistry.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';

contract DeployEmergencyMode is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    currentAddresses.emergencyRegistry = revisionAddresses.emergencyRegistry = address(
      new EmergencyRegistry()
    );

    address owner = config.emergencyRegistry.owner != address(0)
      ? config.emergencyRegistry.owner
      : msg.sender;

    Ownable(address(currentAddresses.emergencyRegistry)).transferOwnership(owner);
  }
}
