// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscScroll} from 'aave-address-book/MiscScroll.sol';
import {MiscMetis} from 'aave-address-book/MiscMetis.sol';
import '../BaseScript.sol';

abstract contract BaseDeployGranularGuardian is BaseScript {
  address public immutable DEFAULT_ADMIN;
  address public immutable RETRY_GUARDIAN;
  address public immutable SOLVE_EMERGENCY_GUARDIAN;
  address public immutable CROSS_CHAIN_CONTROLLER;

  constructor(
    IGranularGuardianAccessControl.InitialGuardians memory initialGuardians,
    address crossChainController
  ) {
    DEFAULT_ADMIN = initialGuardians.defaultAdmin;
    RETRY_GUARDIAN = initialGuardians.retryGuardian;
    SOLVE_EMERGENCY_GUARDIAN = initialGuardians.solveEmergencyGuardian;
    CROSS_CHAIN_CONTROLLER = crossChainController;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    IGranularGuardianAccessControl.InitialGuardians
      memory initialGuardians = IGranularGuardianAccessControl.InitialGuardians({
        defaultAdmin: DEFAULT_ADMIN,
        retryGuardian: RETRY_GUARDIAN,
        solveEmergencyGuardian: SOLVE_EMERGENCY_GUARDIAN
      });
    address granularCCCGuardian = address(
      new GranularGuardianAccessControl(initialGuardians, CROSS_CHAIN_CONTROLLER)
    );

    addresses.granularCCCGuardian = granularCCCGuardian;
  }
}

contract Ethereum is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscEthereum.PROTOCOL_GUARDIAN,
      retryGuardian: 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF,
      solveEmergencyGuardian: MiscEthereum.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Avalanche is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscAvalanche.PROTOCOL_GUARDIAN,
      retryGuardian: 0x3DBA1c4094BC0eE4772A05180B7E0c2F1cFD9c36,
      solveEmergencyGuardian: MiscAvalanche.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscPolygon.PROTOCOL_GUARDIAN,
      retryGuardian: 0xbCEB4f363f2666E2E8E430806F37e97C405c130b,
      solveEmergencyGuardian: MiscPolygon.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscBNB.PROTOCOL_GUARDIAN,
      retryGuardian: 0xE8C5ab722d0b1B7316Cc4034f2BE91A5B1d29964,
      solveEmergencyGuardian: MiscBNB.PROTOCOL_GUARDIAN
    }),
    GovernanceV3BNB.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscGnosis.PROTOCOL_GUARDIAN,
      retryGuardian: 0xcb8a3E864D12190eD2b03cbA0833b15f2c314Ed8,
      solveEmergencyGuardian: MiscGnosis.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Metis is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscMetis.PROTOCOL_GUARDIAN,
      retryGuardian: 0x9853589F951D724D9f7c6724E0fD63F9d888C429,
      solveEmergencyGuardian: MiscMetis.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Metis.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Scroll is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscScroll.PROTOCOL_GUARDIAN,
      retryGuardian: 0x4aAa03F0A61cf93eA252e987b585453578108358,
      solveEmergencyGuardian: MiscScroll.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Scroll.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Optimism is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscOptimism.PROTOCOL_GUARDIAN,
      retryGuardian: 0x3A800fbDeAC82a4d9c68A9FA0a315e095129CDBF,
      solveEmergencyGuardian: MiscOptimism.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscArbitrum.PROTOCOL_GUARDIAN,
      retryGuardian: 0x1Fcd437D8a9a6ea68da858b78b6cf10E8E0bF959,
      solveEmergencyGuardian: MiscArbitrum.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Base is
  BaseDeployGranularGuardian(
    IGranularGuardianAccessControl.InitialGuardians({
      defaultAdmin: MiscBase.PROTOCOL_GUARDIAN,
      retryGuardian: 0x7FDA7C3528ad8f05e62148a700D456898b55f8d2,
      solveEmergencyGuardian: MiscBase.PROTOCOL_GUARDIAN
    }),
    GovernanceV3Base.CROSS_CHAIN_CONTROLLER
  )
{
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BASE;
  }
}
