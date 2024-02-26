// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import '../CCC/Set_CCF_Approved_Senders.s.sol';

abstract contract BaseApproveOwnerOnCCF is BaseSetCCFApprovedSenders {
  function getSendersToApprove() public view override returns (address[] memory) {
    address[] memory addressesToApprove = new address[](1);
    addressesToApprove[0] = _getAddresses(TRANSACTION_NETWORK()).owner;

    return addressesToApprove;
  }
}

contract Ethereum is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Avalanche is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Ethereum_testnet is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Avalanche_testnet is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Polygon_testnet is BaseApproveOwnerOnCCF {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}
