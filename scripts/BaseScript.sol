// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import {ChainIds, TestNetChainIds} from 'aave-helpers/ChainIds.sol';
import {Create2Utils} from 'aave-helpers/ScriptUtils.sol';

struct Addresses {
  address arbAdapter;
  address baseAdapter;
  address ccipAdapter;
  uint256 chainId;
  address clEmergencyOracle;
  address create3Factory;
  address crossChainController;
  address crossChainControllerImpl;
  address emergencyRegistry;
  address gnosisAdapter;
  address granularCCCGuardian;
  address guardian;
  address hlAdapter;
  address lzAdapter;
  address metisAdapter;
  address mockDestination;
  address opAdapter;
  address owner;
  address polAdapter;
  address proxyAdmin;
  address proxyFactory;
  address sameChainAdapter;
  address scrollAdapter;
  address wormholeAdapter;
  address zkevmAdapter;
}

abstract contract BaseScript is Script {
  function TRANSACTION_NETWORK() internal view virtual returns (uint256);

  function _getAddresses(uint256 networkId) internal view virtual returns (Addresses memory);
}
