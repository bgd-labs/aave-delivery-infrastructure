// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../../src/contracts/interfaces/ICrossChainForwarder.sol';

import '../BaseScript.sol';

/**
 * @notice This script needs to be implemented from where the senders are known
 */
abstract contract BaseSetCCFApprovedSenders is BaseScript {
  function getSendersToApprove(DeployerHelpers.Addresses memory addresses) public pure virtual returns (address[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).approveSenders(getSendersToApprove(addresses));
  }
}

contract Ethereum is BaseSetCCFApprovedSenders {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getSendersToApprove(DeployerHelpers.Addresses memory addresses) public pure override returns (address[] memory) {
    address[] memory senders = new address[](1);
    senders[0] = addresses.owner;
    return senders;
  }
}

contract Ethereum_testnet is BaseSetCCFApprovedSenders {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getSendersToApprove(DeployerHelpers.Addresses memory addresses) public pure override returns (address[] memory) {
    address[] memory senders = new address[](1);
    senders[0] = addresses.owner;
    return senders;
  }
}
