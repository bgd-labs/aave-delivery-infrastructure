// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseScript.sol';

contract WriteDeployedAddresses is Script {
  using stdJson for string;

  function run() public {
    Network[] memory networks = new Network[](2);
    // mainnets
    //    networks[0] = Network({
    //      path: DeployerHelpers.getPathByChainId(ChainIds.ETHEREUM),
    //      name: 'ethereum'
    //    });
    //    networks[1] = Network({
    //      path: DeployerHelpers.getPathByChainId(ChainIds.POLYGON),
    //      name: 'polygon'
    //    });
    //    networks[2] = Network({
    //      path: DeployerHelpers.getPathByChainId(ChainIds.AVALANCHE),
    //      name: 'avalanche'
    //    });
    //    networks[3] = Network({
    //      path: DeployerHelpers.getPathByChainId(ChainIds.OPTIMISM),
    //      name: 'optimism'
    //    });
    //    networks[4] = Network({
    //      path: DeployerHelpers.getPathByChainId(ChainIds.ARBITRUM),
    //      name: 'arbitrum'
    //    });
    //    networks[5] = Network({path: DeployerHelpers.getPathByChainId(ChainIds.METIS), name: 'metis'});
    // testnets
    networks[0] = Network({
      path: DeployerHelpers.getPathByChainId(TestNetChainIds.ETHEREUM_SEPOLIA),
      name: 'sepolia'
    });
    //    networks[7] = Network({
    //      path: DeployerHelpers.getPathByChainId(TestNetChainIds.POLYGON_MUMBAI),
    //      name: 'mumbai'
    //    });
    networks[1] = Network({
      path: DeployerHelpers.getPathByChainId(TestNetChainIds.AVALANCHE_FUJI),
      name: 'fuji'
    });
    //    networks[9] = Network({
    //      path: DeployerHelpers.getPathByChainId(TestNetChainIds.OPTIMISM_GOERLI),
    //      name: 'optimismGoerli'
    //    });
    //    networks[10] = Network({
    //      path: DeployerHelpers.getPathByChainId(TestNetChainIds.ARBITRUM_GOERLI),
    //      name: 'arbitrumGoerli'
    //    });
    //    networks[11] = Network({
    //      path: DeployerHelpers.getPathByChainId(TestNetChainIds.METIS_TESTNET),
    //      name: 'metisTestnet'
    //    });

    string memory deployedJson = 'deployments';

    for (uint256 i = 0; i < networks.length; i++) {
      DeployerHelpers.Addresses memory addresses = DeployerHelpers.decodeJson(networks[i].path, vm);
      string memory json = networks[i].name;

      json.serialize('ccipAdapter', addresses.ccipAdapter);
      json.serialize('chainId', addresses.chainId);
      json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
      json.serialize('crossChainController', addresses.crossChainController);
      json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
      json.serialize('emergencyRegistry', addresses.emergencyRegistry);
      json.serialize('guardian', addresses.guardian);
      json.serialize('hlAdapter', addresses.hlAdapter);
      json.serialize('lzAdapter', addresses.lzAdapter);
      json.serialize('owner', addresses.owner);
      json.serialize('polAdapter', addresses.polAdapter);
      json.serialize('proxyAdmin', addresses.proxyAdmin);
      json.serialize('proxyFactory', addresses.proxyFactory);
      json = json.serialize('sameChainAdapter', addresses.sameChainAdapter);

      if (i == networks.length - 1) {
        deployedJson = deployedJson.serialize(networks[i].name, json);
      } else {
        deployedJson.serialize(networks[i].name, json);
      }
    }

    vm.writeJson(deployedJson, './deployments/multiChainCCAddresses.json');
  }
}
