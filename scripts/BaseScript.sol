// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'forge-std/Vm.sol';
import 'forge-std/StdJson.sol';
import {TestNetChainIds} from './contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';

struct Network {
  string path;
  string name;
}

library DeployerHelpers {
  using stdJson for string;

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
    address zkevmAdapter;
  }

  function getPathByChainId(uint256 chainId) internal pure returns (string memory) {
    if (chainId == ChainIds.ETHEREUM) {
      return './deployments/cc/mainnet/eth.json';
    } else if (chainId == ChainIds.POLYGON) {
      return './deployments/cc/mainnet/pol.json';
    } else if (chainId == ChainIds.AVALANCHE) {
      return './deployments/cc/mainnet/avax.json';
    } else if (chainId == ChainIds.ARBITRUM) {
      return './deployments/cc/mainnet/arb.json';
    } else if (chainId == ChainIds.OPTIMISM) {
      return './deployments/cc/mainnet/op.json';
    } else if (chainId == ChainIds.METIS) {
      return './deployments/cc/mainnet/metis.json';
    } else if (chainId == ChainIds.BNB) {
      return './deployments/cc/mainnet/bnb.json';
    } else if (chainId == ChainIds.BASE) {
      return './deployments/cc/mainnet/base.json';
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return './deployments/cc/mainnet/zkevm.json';
    } else if (chainId == ChainIds.GNOSIS) {
      return './deployments/cc/mainnet/gnosis.json';
    }
    if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return './deployments/cc/testnet/sep.json';
    } else if (chainId == TestNetChainIds.ETHEREUM_GOERLI) {
      return './deployments/cc/testnet/goerli.json';
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return './deployments/cc/testnet/mum.json';
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return './deployments/cc/testnet/fuji.json';
    } else if (chainId == TestNetChainIds.ARBITRUM_GOERLI) {
      return './deployments/cc/testnet/arb_go.json';
    } else if (chainId == TestNetChainIds.OPTIMISM_GOERLI) {
      return './deployments/cc/testnet/op_go.json';
    } else if (chainId == TestNetChainIds.METIS_TESTNET) {
      return './deployments/cc/testnet/met_test.json';
    } else if (chainId == TestNetChainIds.BNB_TESTNET) {
      return './deployments/cc/testnet/bnb_test.json';
    } else if (chainId == TestNetChainIds.BASE_GOERLI) {
      return './deployments/cc/testnet/base_go.json';
    } else if (chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI) {
      return './deployments/cc/testnet/zkevm_go.json';
    } else if (chainId == TestNetChainIds.GNOSIS_CHIADO) {
      return './deployments/cc/testnet/gno_chiado.json';
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
      sameChainAdapter: abi.decode(persistedJson.parseRaw('.sameChainAdapter'), (address)),
      chainId: abi.decode(persistedJson.parseRaw('.chainId'), (uint256)),
      emergencyRegistry: abi.decode(persistedJson.parseRaw('.emergencyRegistry'), (address)),
      lzAdapter: abi.decode(persistedJson.parseRaw('.lzAdapter'), (address)),
      hlAdapter: abi.decode(persistedJson.parseRaw('.hlAdapter'), (address)),
      opAdapter: abi.decode(persistedJson.parseRaw('.opAdapter'), (address)),
      arbAdapter: abi.decode(persistedJson.parseRaw('.arbAdapter'), (address)),
      metisAdapter: abi.decode(persistedJson.parseRaw('.metisAdapter'), (address)),
      polAdapter: abi.decode(persistedJson.parseRaw('.polAdapter'), (address)),
      mockDestination: abi.decode(persistedJson.parseRaw('.mockDestination'), (address)),
      baseAdapter: abi.decode(persistedJson.parseRaw('.baseAdapter'), (address)),
      zkevmAdapter: abi.decode(persistedJson.parseRaw('.zkevmAdapter'), (address)),
      gnosisAdapter: abi.decode(persistedJson.parseRaw('.gnosisAdapter'), (address))
    });

    return addresses;
  }

  function encodeJson(string memory path, Addresses memory addresses, Vm vm) internal {
    string memory json = 'addresses';
    json.serialize('arbAdapter', addresses.arbAdapter);
    json.serialize('baseAdapter', addresses.baseAdapter);
    json.serialize('ccipAdapter', addresses.ccipAdapter);
    json.serialize('chainId', addresses.chainId);
    json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
    json.serialize('create3Factory', addresses.create3Factory);
    json.serialize('crossChainController', addresses.crossChainController);
    json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
    json.serialize('emergencyRegistry', addresses.emergencyRegistry);
    json.serialize('gnosisAdapter', addresses.gnosisAdapter);
    json.serialize('guardian', addresses.guardian);
    json.serialize('hlAdapter', addresses.hlAdapter);
    json.serialize('lzAdapter', addresses.lzAdapter);
    json.serialize('metisAdapter', addresses.metisAdapter);
    json.serialize('mockDestination', addresses.mockDestination);
    json.serialize('opAdapter', addresses.opAdapter);
    json.serialize('owner', addresses.owner);
    json.serialize('polAdapter', addresses.polAdapter);
    json.serialize('proxyAdmin', addresses.proxyAdmin);
    json.serialize('proxyFactory', addresses.proxyFactory);
    json.serialize('sameChainAdapter', addresses.sameChainAdapter);
    json = json.serialize('zkevmAdapter', addresses.zkevmAdapter);
    vm.writeJson(json, path);
  }
}

library Constants {
  address public constant OWNER = 0xf71fc92e2949ccF6A5Fd369a0b402ba80Bc61E02;
  bytes32 public constant ADMIN_SALT = keccak256(bytes('Proxy Admin'));
  bytes32 public constant CCC_SALT = keccak256(bytes('a.DI Cross Chain Controller'));
  bytes32 public constant CREATE3_FACTORY_SALT = keccak256(bytes('Create3 Factory'));
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
