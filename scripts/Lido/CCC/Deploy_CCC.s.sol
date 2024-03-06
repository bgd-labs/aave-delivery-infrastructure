// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TransparentUpgradeableProxy} from 'solidity-utils/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {Create3Factory, ICreate3Factory} from 'solidity-utils/contracts/create3/Create3Factory.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';

import {CrossChainController, ICrossChainController} from '../../../src/contracts/CrossChainController.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../../../src/contracts/CrossChainControllerWithEmergencyMode.sol';

import '../BaseScript.sol';

abstract contract BaseCCCNetworkDeployment is BaseScript {
  function CL_EMERGENCY_ORACLE() public view virtual returns (address) {
    return address(0);
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    ICrossChainController crossChainControllerImpl;
    address crossChainController;

    // if address is 0 means that ccc will not be emergency consumer
    if (CL_EMERGENCY_ORACLE() == address(0)) {
      crossChainControllerImpl = new CrossChainController();

      crossChainController = TransparentProxyFactory(addresses.proxyFactory).createDeterministic(
        address(crossChainControllerImpl),
        addresses.proxyAdmin,
        abi.encodeWithSelector(
          CrossChainController.initialize.selector,
          addresses.owner,
          addresses.guardian,
          new ICrossChainController.ConfirmationInput[](0),
          new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
          new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
          new address[](0)
        ),
        Constants.CCC_SALT
      );
    } else {
      crossChainControllerImpl = ICrossChainController(
        address(new CrossChainControllerWithEmergencyMode(CL_EMERGENCY_ORACLE()))
      );

      crossChainController = TransparentProxyFactory(addresses.proxyFactory).createDeterministic(
        address(crossChainControllerImpl),
        addresses.proxyAdmin,
        abi.encodeWithSelector(
          ICrossChainControllerWithEmergencyMode.initialize.selector,
          addresses.owner,
          addresses.guardian,
          CL_EMERGENCY_ORACLE(),
          new ICrossChainController.ConfirmationInput[](0),
          new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
          new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
          new address[](0)
        ),
        Constants.CCC_SALT
      );

      addresses.clEmergencyOracle = CL_EMERGENCY_ORACLE();
    }

    addresses.crossChainController = crossChainController;
    addresses.crossChainControllerImpl = address(crossChainControllerImpl);
  }
}

contract Ethereum is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Ethereum_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Binance_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}
