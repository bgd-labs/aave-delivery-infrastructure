// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../DeploymentConfiguration.sol';
import {CrossChainController, ICrossChainController} from '../../src/contracts/CrossChainController.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../../src/contracts/CrossChainControllerWithEmergencyMode.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';

contract Deploy_CCC is DeploymentConfigurationBaseScript {
  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    CCC memory cccConfig = config.ccc;

    // deploy CCC implementation
    address crossChainControllerImpl;
    if (cccConfig.clEmergencyOracle == address(0)) {
      crossChainControllerImpl = address(new CrossChainController());
    } else {
      crossChainControllerImpl = address(
        new CrossChainControllerWithEmergencyMode(cccConfig.clEmergencyOracle)
      );
    }

    // Deploy Proxy and set implementation
    if (cccConfig.onlyImpl == false) {
      address crossChainController;

      address proxyAdmin = revisionAddresses.proxyAdmin != address(0)
        ? revisionAddresses.proxyAdmin
        : currentAddresses.proxyAdmin != address(0)
        ? currentAddresses.proxyAdmin
        : address(0);

      address proxyFactory = revisionAddresses.proxyFactory != address(0)
        ? revisionAddresses.proxyFactory
        : currentAddresses.proxyFactory != address(0)
        ? currentAddresses.proxyFactory
        : address(0);

      address owner = cccConfig.owner != address(0) ? cccConfig.owner : msg.sender;
      address guardian = cccConfig.guardian != address(0) ? cccConfig.guardian : msg.sender;

      require(proxyAdmin != address(0), 'PROXY ADMIN IS NEEDED');
      require(proxyFactory != address(0), 'PROXY FACTORY IS NEEDED');
      require(bytes(cccConfig.salt).length > 0, 'SALT NEEDED');
      require(owner != address(0), 'OWNER IS NEEDED');
      require(guardian != address(0), 'GUARDIAN IS NEEDED');

      // if address is 0 means that ccc will not be emergency consumer
      if (cccConfig.clEmergencyOracle == address(0)) {
        crossChainController = TransparentProxyFactory(proxyFactory).createDeterministic(
          crossChainControllerImpl,
          proxyAdmin,
          abi.encodeWithSelector(
            CrossChainController.initialize.selector,
            owner,
            guardian,
            new ICrossChainController.ConfirmationInput[](0),
            new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
            new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
            new address[](0)
          ),
          keccak256(bytes(cccConfig.salt))
        );
      } else {
        crossChainController = TransparentProxyFactory(proxyFactory).createDeterministic(
          crossChainControllerImpl,
          proxyAdmin,
          abi.encodeWithSelector(
            ICrossChainControllerWithEmergencyMode.initialize.selector,
            owner,
            guardian,
            cccConfig.clEmergencyOracle,
            new ICrossChainController.ConfirmationInput[](0),
            new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
            new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
            new address[](0)
          ),
          keccak256(bytes(cccConfig.salt))
        );

        revisionAddresses.clEmergencyOracle = currentAddresses.clEmergencyOracle = cccConfig
          .clEmergencyOracle;
      }
      revisionAddresses.crossChainController = currentAddresses
        .crossChainController = crossChainController;
    }

    revisionAddresses.crossChainControllerImpl = currentAddresses
      .crossChainControllerImpl = crossChainControllerImpl;
  }
}
