// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import 'forge-std/StdJson.sol';

import {TestNetChainIds} from '../contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';

struct Network {
  string path;
  string name;
}

library DeployerHelpers {
  using stdJson for string;

  struct Addresses {
    address ccipAdapter;
    uint256 chainId;
    address clEmergencyOracle;
    address create3Factory;
    address crossChainController;
    address crossChainControllerImpl;
    address emergencyRegistry;
    address guardian;
    address hlAdapter;
    address lzAdapter;
    address mockDestination;
    address owner;
    address polAdapter;
    address proxyAdmin;
    address proxyFactory;
    address wormholeAdapter;
    address executor;
  }

  function getPathByChainId(uint256 chainId) internal pure returns (string memory) {
    if (chainId == ChainIds.ETHEREUM) {
      return './deployments/cc/mainnet/eth.json';
    } else if (chainId == ChainIds.POLYGON) {
      return './deployments/cc/mainnet/pol.json';
    } else if (chainId == ChainIds.BNB) {
      return './deployments/cc/mainnet/bnb.json';
    }

    if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return './deployments/cc/testnet/sep.json';
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return './deployments/cc/testnet/mum.json';
    } else if (chainId == TestNetChainIds.BNB_TESTNET) {
      return './deployments/cc/testnet/bnb_test.json';
    } else {
      revert('chain id is not supported');
    }
  }

  function decodeJson(string memory path, Vm vm) internal view returns (Addresses memory) {
    string memory persistedJson = vm.readFile(path);

    Addresses memory addresses = Addresses({
      proxyAdmin: abi.decode(persistedJson.parseRaw('.proxyAdmin'), (address)),
      proxyFactory: abi.decode(persistedJson.parseRaw('.proxyFactory'), (address)),
      owner: abi.decode(persistedJson.parseRaw('.owner'), (address)),
      guardian: abi.decode(persistedJson.parseRaw('.guardian'), (address)),
      clEmergencyOracle: abi.decode(persistedJson.parseRaw('.clEmergencyOracle'), (address)),
      create3Factory: abi.decode(persistedJson.parseRaw('.create3Factory'), (address)),
      crossChainController: abi.decode(persistedJson.parseRaw('.crossChainController'), (address)),
      crossChainControllerImpl: abi.decode(
        persistedJson.parseRaw('.crossChainControllerImpl'),
        (address)
      ),
      ccipAdapter: abi.decode(persistedJson.parseRaw('.ccipAdapter'), (address)),
      chainId: abi.decode(persistedJson.parseRaw('.chainId'), (uint256)),
      emergencyRegistry: abi.decode(persistedJson.parseRaw('.emergencyRegistry'), (address)),
      hlAdapter: abi.decode(persistedJson.parseRaw('.hlAdapter'), (address)),
      lzAdapter: abi.decode(persistedJson.parseRaw('.lzAdapter'), (address)),
      polAdapter: abi.decode(persistedJson.parseRaw('.polAdapter'), (address)),
      wormholeAdapter: abi.decode(persistedJson.parseRaw('.wormholeAdapter'), (address)),
      mockDestination: abi.decode(persistedJson.parseRaw('.mockDestination'), (address)),
      executor: abi.decode(persistedJson.parseRaw('.executor'), (address))
    });

    return addresses;
  }

  function encodeJson(string memory path, Addresses memory addresses, Vm vm) internal {
    string memory json = 'addresses';
    json.serialize('ccipAdapter', addresses.ccipAdapter);
    json.serialize('chainId', addresses.chainId);
    json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
    json.serialize('create3Factory', addresses.create3Factory);
    json.serialize('crossChainController', addresses.crossChainController);
    json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
    json.serialize('emergencyRegistry', addresses.emergencyRegistry);
    json.serialize('guardian', addresses.guardian);
    json.serialize('hlAdapter', addresses.hlAdapter);
    json.serialize('lzAdapter', addresses.lzAdapter);
    json.serialize('mockDestination', addresses.mockDestination);
    json.serialize('owner', addresses.owner);
    json.serialize('polAdapter', addresses.polAdapter);
    json.serialize('wormholeAdapter', addresses.wormholeAdapter);
    json.serialize('proxyAdmin', addresses.proxyAdmin);
    json.serialize('executor', addresses.executor);
    json = json.serialize('proxyFactory', addresses.proxyFactory);
    vm.writeJson(json, path);
  }
}

library Constants {
  address public constant OWNER = 0x77d302662a84c0924a8290f72200e1F43D28430F; // Yuri T Deployer address
  bytes32 public constant ADMIN_SALT = keccak256(bytes('Lido a.DI Proxy Admin on Testnet'));
  bytes32 public constant CCC_SALT = keccak256(bytes('Lido a.DI Cross Chain Controller on Testnet'));
  bytes32 public constant CREATE3_FACTORY_SALT = keccak256(bytes('Lido a.DI Create3 Factory on Testnet'));
}

abstract contract BaseScript is Script {
  function TRANSACTION_NETWORK() public view virtual returns (uint256);

  function getAddresses(
    uint256 networkId
  ) external view returns (DeployerHelpers.Addresses memory) {
    return DeployerHelpers.decodeJson(DeployerHelpers.getPathByChainId(networkId), vm);
  }

  function _getAddresses(
    uint256 networkId
  ) internal view returns (DeployerHelpers.Addresses memory) {
    try this.getAddresses(networkId) returns (DeployerHelpers.Addresses memory addresses) {
      return addresses;
    } catch (bytes memory) {
      DeployerHelpers.Addresses memory empty;
      return empty;
    }
  }

  function _setAddresses(uint256 networkId, DeployerHelpers.Addresses memory addresses) internal {
    DeployerHelpers.encodeJson(DeployerHelpers.getPathByChainId(networkId), addresses, vm);
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal virtual;

  function run() public {
    vm.startBroadcast();
    // ----------------- Persist addresses -----------------------------------------------------------------------------
    DeployerHelpers.Addresses memory addresses = _getAddresses(TRANSACTION_NETWORK());
    // -----------------------------------------------------------------------------------------------------------------
    _execute(addresses);
    // ----------------- Persist addresses -----------------------------------------------------------------------------
    _setAddresses(TRANSACTION_NETWORK(), addresses);
    // -----------------------------------------------------------------------------------------------------------------
    vm.stopBroadcast();
  }
}
