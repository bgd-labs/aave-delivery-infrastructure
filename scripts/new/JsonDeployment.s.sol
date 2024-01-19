// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.12;
//import '../BaseScript.sol';
import '../DeploymentConfiguration.sol';

contract JsonDeployment is DeploymentConfigurationHelpers, Script {
  function _getDeploymentConfig() internal view returns (ChainDeploymentInfo[] memory) {
    // get deployment json path
    string memory key = 'DEPLOYMENT_VERSION';
    // check that file with version exists and that it has not already been used (> current version)

    string memory version = vm.envString(key);
    string memory deploymentJsonPath = DeploymentConfigurationHelpers
      ._getDeploymentJsonPathByVersion(version);

    // get configuration
    return _decodeConfig(deploymentJsonPath, vm);
  }

  function run() public {
    ChainDeploymentInfo[] memory config = _getDeploymentConfig();

    for (uint256 i = 0; i < config.length; i++) {
      console.log('chainId', config[i].proxies.proxyAdmin.deployedAddress);
    }
  }
}
