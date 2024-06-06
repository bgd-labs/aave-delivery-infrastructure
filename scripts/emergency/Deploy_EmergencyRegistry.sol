// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {EmergencyRegistry} from '../../src/contracts/emergency/EmergencyRegistry.sol';
import {Ownable} from 'solidity-utils/contracts/oz-common/Ownable.sol';
import '../BaseScript.sol';

library EmergencyRegistryDeploymentHelper {
  function getEmergencyRegistryCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(EmergencyRegistry).creationCode, abi.encode());
  }
}

abstract contract BaseDeployEmergencyMode is BaseScript {
  function OWNER() public view virtual returns (address) {
    return address(msg.sender);
  }

  function SALT() internal view virtual returns (string memory) {
    return 'a.DI EmergencyRegistry';
  }

  function _deployEmergencyRegistry() internal returns (address) {
    bytes memory erCode = EmergencyRegistryDeploymentHelper.getEmergencyRegistryCode();

    return Create2Utils.create2Deploy(keccak256(abi.encode(SALT())), erCode);
  }
}
