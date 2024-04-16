// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {CrossChainControllerUpgradeRev2, IReinitialize} from '../../src/contracts/revisions/update_to_rev_2/CrossChainController.sol';
import {CrossChainControllerWithEmergencyModeUpgradeRev2} from '../../src/contracts/revisions/update_to_rev_2/CrossChainControllerWithEmergencyMode.sol';
import {TransparentUpgradeableProxy} from 'solidity-utils/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {ProxyAdmin} from 'solidity-utils/contracts/transparent-proxy/ProxyAdmin.sol';

abstract contract BaseCCCUpdate is BaseScript {
  function CL_EMERGENCY_ORACLE() public view virtual returns (address) {
    return address(0);
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    address crossChainControllerImpl;

    // if address is 0 means that ccc will not be emergency consumer
    if (CL_EMERGENCY_ORACLE() == address(0)) {
      crossChainControllerImpl = address(new CrossChainControllerUpgradeRev2());
    } else {
      crossChainControllerImpl = address(
        new CrossChainControllerWithEmergencyModeUpgradeRev2(CL_EMERGENCY_ORACLE())
      );

      addresses.clEmergencyOracle = CL_EMERGENCY_ORACLE();
    }

    addresses.crossChainControllerImpl = crossChainControllerImpl;
  }
}

contract Ethereum is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseCCCUpdate {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xDAFA1989A504c48Ee20a582f2891eeB25E2fA23F;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseCCCUpdate {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0x41185495Bc8297a65DC46f94001DC7233775EbEe;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Arbitrum is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Optimism is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Metis is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Binance is BaseCCCUpdate {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xcabb46FfB38c93348Df16558DF156e9f68F9F7F1;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Base is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Gnosis is BaseCCCUpdate {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0xF937ffAeA1363e4Fa260760bDFA2aA8Fc911F84D;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Zkevm is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }
}

contract Scroll is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Celo is BaseCCCUpdate {
  function CL_EMERGENCY_ORACLE() public pure override returns (address) {
    return 0x91b21900E91CD302EBeD05E45D8f270ddAED944d;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Ethereum_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Avalanche_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Arbitrum_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ARBITRUM_SEPOLIA;
  }
}

contract Optimism_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_SEPOLIA;
  }
}

contract Metis_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }
}

contract Binance_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}

contract Base_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BASE_SEPOLIA;
  }
}

contract Gnosis_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }
}

contract Scroll_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.SCROLL_SEPOLIA;
  }
}

contract Celo_testnet is BaseCCCUpdate {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }
}
