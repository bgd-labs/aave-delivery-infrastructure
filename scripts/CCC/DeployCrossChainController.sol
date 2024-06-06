// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {CrossChainController, ICrossChainController} from '../../src/contracts/CrossChainController.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../../src/contracts/CrossChainControllerWithEmergencyMode.sol';

library CCCImplDeploymentHelper {
  function getCCCImplCode(address emergencyOracle) internal pure returns (bytes memory) {
    bytes memory cccImplCode = emergencyOracle == address(0)
      ? abi.encodePacked(type(CrossChainController).creationCode, abi.encode())
      : abi.encodePacked(
        type(CrossChainControllerWithEmergencyMode).creationCode,
        abi.encode(emergencyOracle)
      );

    return cccImplCode;
  }
}

abstract contract BaseCCCDeploy is BaseScript {
  function CL_EMERGENCY_ORACLE() public view virtual returns (address) {
    return address(0);
  }

  function SALT() internal view virtual returns (string memory) {
    return 'a.DI CrossChainController';
  }

  function _deployCCCImpl() internal returns (address) {
    bytes memory cccCode = CCCImplDeploymentHelper.getCCCImplCode(CL_EMERGENCY_ORACLE());

    return Create2Utils.create2Deploy(keccak256(abi.encode(SALT())), cccCode);
  }
}
