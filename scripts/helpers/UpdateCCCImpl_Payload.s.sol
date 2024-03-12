// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {TransparentUpgradeableProxy} from 'solidity-utils/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {ProxyAdmin} from 'solidity-utils/contracts/transparent-proxy/ProxyAdmin.sol';

contract UpdateCCCImpl {
  address public immutable PROXY_ADMIN;
  address public immutable CCC;
  address public immutable CCC_IMPL;

  constructor(address proxyAdmin, address ccc, address cccImpl) {
    PROXY_ADMIN = proxyAdmin;
    CCC = ccc;
    CCC_IMPL = cccImpl;
  }

  function execute() external {
    ProxyAdmin(PROXY_ADMIN).upgradeAndCall(
      TransparentUpgradeableProxy(payable(CCC)),
      CCC_IMPL,
      abi.encodeWithSignature('initializeRevision()')
    );
  }
}

abstract contract BaseCCCUpdatePayload is BaseScript {
  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    address crossChainControllerImpl;

    new UpdateCCCImpl(
      addresses.proxyAdmin,
      addresses.crossChainController,
      addresses.crossChainControllerImpl
    );
  }
}

contract Celo is BaseCCCUpdatePayload {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO;
  }
}
