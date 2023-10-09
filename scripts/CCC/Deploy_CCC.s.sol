// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {CrossChainController, ICrossChainController} from '../../src/contracts/CrossChainController.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../../src/contracts/CrossChainControllerWithEmergencyMode.sol';
import {TransparentUpgradeableProxy} from 'solidity-utils/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {Create3Factory, ICreate3Factory} from 'solidity-utils/contracts/create3/Create3Factory.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';

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
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xDAFA1989A504c48Ee20a582f2891eeB25E2fA23F;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0x41185495Bc8297a65DC46f94001DC7233775EbEe;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Arbitrum is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Optimism is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Metis is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Binance is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xcabb46FfB38c93348Df16558DF156e9f68F9F7F1;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Base is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Gnosis is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xF937ffAeA1363e4Fa260760bDFA2aA8Fc911F84D;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
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

contract Avalanche_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Arbitrum_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ARBITRUM_GOERLI;
  }
}

contract Optimism_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }
}

contract Metis_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }
}

contract Binance_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}

contract Base_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BASE_GOERLI;
  }
}

contract Gnosis_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }
}
