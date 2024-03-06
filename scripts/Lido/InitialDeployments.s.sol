// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {Create3Factory} from 'solidity-utils/contracts/create3/Create3Factory.sol';

import {LidoAddressBook} from './LidoAddressBook.sol';

import './BaseScript.sol';

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
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_ETHEREUM;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_ETHEREUM;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_ETHEREUM;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_ETHEREUM;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseInitialDeployment {
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_POLYGON;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_POLYGON;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_POLYGON;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_POLYGON;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is BaseInitialDeployment {
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_BINANCE;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_BINANCE;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_BINANCE;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_BINANCE;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Ethereum_testnet is BaseInitialDeployment {
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_ETHEREUM_TESTNET;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_ETHEREUM_TESTNET;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_ETHEREUM_TESTNET;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_ETHEREUM_TESTNET;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseInitialDeployment {
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_POLYGON_TESTNET;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_POLYGON_TESTNET;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_POLYGON_TESTNET;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_POLYGON_TESTNET;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Binance_testnet is BaseInitialDeployment {
  function CREATE3_FACTORY() public pure override returns (address) {
    return LidoAddressBook.CREATE3_FACTORY_BINANCE_TESTNET;
  }

  function TRANSPARENT_PROXY_FACTORY() public pure override returns (address) {
    return LidoAddressBook.TRANSPARENT_PROXY_FACTORY_BINANCE_TESTNET;
  }

  function PROXY_ADMIN() public pure override returns (address) {
    return LidoAddressBook.PROXY_ADMIN_BINANCE_TESTNET;
  }

  function GUARDIAN() public pure override returns (address) {
    return LidoAddressBook.GUARDIAN_BINANCE_TESTNET;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}
