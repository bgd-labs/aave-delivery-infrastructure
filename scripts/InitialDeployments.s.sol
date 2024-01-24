// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {Create3Factory} from 'solidity-utils/contracts/create3/Create3Factory.sol';
import './DeploymentConfiguration.sol';

contract InitialDeployments is DeploymentConfigurationBaseScript {
  // TODO: maybe these methods make sense to put them in the base script as could be useful in other
  // deployment scripts
  function getGuardian(
    ChainDeploymentInfo memory config,
    Addresses memory currentAddresses
  ) internal view returns (address) {
    if (config.guardian != address(0)) {
      return config.guardian;
    } else if (AddressBookMiscHelper.getProtocolGuardian(config.chainId) != address(0)) {
      return AddressBookMiscHelper.getProtocolGuardian(config.chainId);
    } else if (currentAddresses.guardian != address(0)) {
      return currentAddresses.guardian;
    } else {
      return msg.sender;
    }
  }

  function getCreate3Factory(
    ChainDeploymentInfo memory config,
    Addresses memory currentAddresses
  ) internal returns (address) {
    if (config.proxies.create3.deployedAddress != address(0)) {
      return config.proxies.create3.deployedAddress;
    } else if (AddressBookMiscHelper.getCreate3Factory(config.chainId) != address(0)) {
      return AddressBookMiscHelper.getCreate3Factory(config.chainId);
    } else if (currentAddresses.create3Factory != address(0)) {
      return currentAddresses.create3Factory;
    } else if (bytes(config.proxies.create3.salt).length != 0) {
      // some networks don't have create2
      if (config.chainId == ChainIds.METIS || config.chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
        return address(new Create3Factory());
      } else {
        return
          address(new Create3Factory{salt: keccak256(abi.encode(config.proxies.create3.salt))}());
      }
    } else {
      return address(0);
    }
  }

  function getProxyFactory(
    ChainDeploymentInfo memory config,
    Addresses memory currentAddresses
  ) internal returns (address) {
    if (config.proxies.transparentProxyFactory.deployedAddress != address(0)) {
      return config.proxies.transparentProxyFactory.deployedAddress;
    } else if (AddressBookMiscHelper.getTransparentProxyFactory(config.chainId) != address(0)) {
      return AddressBookMiscHelper.getTransparentProxyFactory(config.chainId);
    } else if (currentAddresses.proxyFactory != address(0)) {
      return currentAddresses.proxyFactory;
    } else if (bytes(config.proxies.transparentProxyFactory.salt).length != 0) {
      return address(new TransparentProxyFactory());
    } else {
      return address(0);
    }
  }

  function getProxyAdmin(
    ChainDeploymentInfo memory config,
    Addresses memory currentAddresses
  ) internal returns (address) {
    if (config.proxies.proxyAdmin.deployedAddress != address(0)) {
      return config.proxies.proxyAdmin.deployedAddress;
    } else if (AddressBookMiscHelper.getProxyAdmin(config.chainId) != address(0)) {
      return AddressBookMiscHelper.getProxyAdmin(config.chainId);
    } else if (currentAddresses.proxyFactory != address(0)) {
      return currentAddresses.proxyFactory;
    } else if (bytes(config.proxies.proxyAdmin.salt).length != 0) {
      require(currentAddresses.proxyFactory != address(0), 'INCORRECT_PROXY_FACTORY_ADDRESS');
      return
        TransparentProxyFactory(currentAddresses.proxyFactory).createDeterministicProxyAdmin(
          config.proxies.proxyAdmin.owner != address(0)
            ? config.proxies.proxyAdmin.owner
            : msg.sender,
          keccak256(abi.encode(config.proxies.proxyAdmin.salt))
        );
    } else {
      return address(0);
    }
  }

  function _execute(
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config
  ) internal override {
    // TODO: not sure if it makes sense to update both current and revision. Provably we could just
    // compare if new address is different than current then update both. if not, maybe there is
    // no need to update anything
    currentAddresses.create3Factory = revisionAddresses.create3Factory = getCreate3Factory(
      config,
      currentAddresses
    );
    //    currentAddresses.proxyFactory = revisionAddresses.proxyFactory = getProxyFactory(
    //      config,
    //      currentAddresses
    //    );
    //    currentAddresses.proxyAdmin = revisionAddresses.proxyAdmin = getProxyAdmin(
    //      config,
    //      currentAddresses
    //    );

    currentAddresses.guardian = revisionAddresses.guardian = getGuardian(config, currentAddresses);
  }
}
