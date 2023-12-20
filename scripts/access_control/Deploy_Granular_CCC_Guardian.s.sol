// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
//import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
//import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import '../BaseScript.sol';

abstract contract BaseDeployGranularGuardian is BaseScript {
  function AAVE_GUARDIAN() public view virtual returns (address);

  function RETRY_GUARDIAN() public view virtual returns (address);

  function CROSS_CHAIN_CONTROLLER() public view virtual returns (address);

  function _execute(DeployerHelpers.Addresses memory) internal override {
    new GranularGuardianAccessControl(
      AAVE_GUARDIAN(),
      RETRY_GUARDIAN(),
      AAVE_GUARDIAN(),
      CROSS_CHAIN_CONTROLLER()
    );
  }
}

//contract Ethereum is BaseDeployGranularGuardian {
//  function AAVE_GUARDIAN() public pure view override returns (address) {
//    return MiscEthereum.PROTOCOL_GUARDIAN;
//  }
//
//  function RETRY_GUARDIAN() public pure view override returns (address) {
//    return 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF;
//  }
//
//  function CROSS_CHAIN_CONTROLLER() public pure view override returns (address) {
//    return GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER;
//  }
//
//  function TRANSACTION_NETWORK() public pure override returns (uint256) {
//    return ChainIds.ETHEREUM;
//  }
//}

contract Avalanche is BaseDeployGranularGuardian {
  function AAVE_GUARDIAN() public pure override returns (address) {
    return MiscAvalanche.PROTOCOL_GUARDIAN;
  }

  function RETRY_GUARDIAN() public pure override returns (address) {
    return 0x3DBA1c4094BC0eE4772A05180B7E0c2F1cFD9c36;
  }

  function CROSS_CHAIN_CONTROLLER() public pure override returns (address) {
    return GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is BaseDeployGranularGuardian {
  function AAVE_GUARDIAN() public pure override returns (address) {
    return MiscPolygon.PROTOCOL_GUARDIAN;
  }

  function RETRY_GUARDIAN() public pure override returns (address) {
    return 0xbCEB4f363f2666E2E8E430806F37e97C405c130b;
  }

  function CROSS_CHAIN_CONTROLLER() public pure override returns (address) {
    return GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is BaseDeployGranularGuardian {
  function AAVE_GUARDIAN() public pure override returns (address) {
    return MiscBNB.PROTOCOL_GUARDIAN;
  }

  function RETRY_GUARDIAN() public pure override returns (address) {
    return 0xE8C5ab722d0b1B7316Cc4034f2BE91A5B1d29964;
  }

  function CROSS_CHAIN_CONTROLLER() public pure override returns (address) {
    return GovernanceV3BNB.CROSS_CHAIN_CONTROLLER;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is BaseDeployGranularGuardian {
  function AAVE_GUARDIAN() public pure override returns (address) {
    return MiscGnosis.PROTOCOL_GUARDIAN;
  }

  function RETRY_GUARDIAN() public pure override returns (address) {
    return 0xcb8a3E864D12190eD2b03cbA0833b15f2c314Ed8;
  }

  function CROSS_CHAIN_CONTROLLER() public pure override returns (address) {
    return GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}
