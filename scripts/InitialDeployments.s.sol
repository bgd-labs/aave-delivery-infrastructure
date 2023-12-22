// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseScript.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {Create3Factory} from 'solidity-utils/contracts/create3/Create3Factory.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscMetis} from 'aave-address-book/MiscMetis.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';

abstract contract BaseInitialDeployment is BaseScript {
  function OWNER() public virtual returns (address) {
    return address(msg.sender); // as first owner we set deployer, this way its easier to configure
  }

  function GUARDIAN() public virtual returns (address) {
    return address(msg.sender);
  }

  function TRANSPARENT_PROXY_FACTORY() public pure virtual returns (address) {
    return address(0);
  }

  function PROXY_ADMIN() public virtual returns (address) {
    return address(0);
  }

  function CREATE3_FACTORY() public pure virtual returns (address) {
    return address(0);
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.create3Factory = CREATE3_FACTORY() == address(0)
      ? address(new Create3Factory{salt: Constants.CREATE3_FACTORY_SALT}())
      : CREATE3_FACTORY();
    addresses.proxyFactory = TRANSPARENT_PROXY_FACTORY() == address(0)
      ? address(new TransparentProxyFactory())
      : TRANSPARENT_PROXY_FACTORY();
    addresses.proxyAdmin = PROXY_ADMIN() == address(0)
      ? TransparentProxyFactory(addresses.proxyFactory).createDeterministicProxyAdmin(
        OWNER(),
        Constants.ADMIN_SALT
      )
      : PROXY_ADMIN();
    addresses.chainId = TRANSACTION_NETWORK();
    addresses.owner = OWNER();
    addresses.guardian = GUARDIAN();
  }
}

contract Ethereum is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscEthereum.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscEthereum.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xCA76Ebd8617a03126B6FB84F9b1c1A0fB71C2633;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscPolygon.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscPolygon.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0x1450F2898D6bA2710C98BE9CAF3041330eD5ae58;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscAvalanche.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscAvalanche.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xa35b76E4935449E33C56aB24b23fcd3246f13470;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Optimism is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscOptimism.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscOptimism.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xE50c8C619d05ff98b22Adf991F17602C774F785c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscArbitrum.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscArbitrum.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xbbd9f90699c1FA0D7A65870D241DD1f1217c96Eb;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Metis is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscMetis.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscMetis.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xF6Db48C5968A9eBCB935786435530f28e32Cc501;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Binance is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscBNB.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscBNB.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xF6Db48C5968A9eBCB935786435530f28e32Cc501;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscGnosis.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscGnosis.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0xF163b8698821cefbD33Cf449764d69Ea445cE23D;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Base is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return MiscBase.TRANSPARENT_PROXY_FACTORY;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return MiscBase.PROXY_ADMIN;
  }

  function GUARDIAN() public pure override returns (address) {
    return 0x9e10C0A1Eb8FF6a0AaA53a62C7a338f35D7D9a2A;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Zkevm is BaseInitialDeployment {
  //  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
  //    return AaveMisc.TRANSPARENT_PROXY_FACTORY_ZKEVM;
  //  }
  //
  //  function PROXY_ADMIN() public pure override returns (address) {
  //    return AaveMisc.PROXY_ADMIN_ZKEVM;
  //  }
  //
  //  function GUARDIAN() public pure override returns (address) {
  //    return ;
  //  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }
}

contract Ethereum_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Avalanche_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Arbitrum_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ARBITRUM_GOERLI;
  }
}

contract Optimism_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }
}

contract Metis_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }
}

contract Binance_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}

contract Base_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BASE_GOERLI;
  }
}

contract Gnosis_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }
}

contract Zkevm_testnet is BaseInitialDeployment {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_ZK_EVM_GOERLI;
  }
}
