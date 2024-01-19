// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TestNetChainIds} from '../contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';

library StringUtils {
  function eq(string memory a, string memory b) public pure returns (bool) {
    return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
  }
}

library PathHelpers {
  using StringUtils for string;

  function getDeploymentJsonPathByVersion(
    string memory version
  ) internal pure returns (string memory) {
    string memory path = string.concat(
      './deployments/deployment_configurations/deploymentConfigs_',
      version
    );
    return string.concat(path, '.json');
  }

  function getCurrentDeploymentPathByChainId(
    uint256 chainId
  ) internal pure returns (string memory) {
    string memory path = string.concat('./deployments/current/', getChainNameById(chainId));
    return string.concat(path, '.json');
  }

  function getNetworkRevisionDeploymentPath(
    uint256 chainId,
    string memory revision
  ) internal pure returns (string memory) {
    string memory networkName = string.concat(getChainNameById(chainId), '_');
    string memory networkWithRevision = string.concat(networkName, revision);
    string memory path = string.concat('./deployments/revisions/', networkWithRevision);
    return string.concat(path, '.json');
  }

  function getChainNameById(uint256 chainId) internal pure returns (string memory) {
    if (chainId == ChainIds.ETHEREUM) {
      return 'ethereum';
    } else if (chainId == ChainIds.POLYGON) {
      return 'polygon';
    } else if (chainId == ChainIds.AVALANCHE) {
      return 'avalanche';
    } else if (chainId == ChainIds.ARBITRUM) {
      return 'arbitrum';
    } else if (chainId == ChainIds.OPTIMISM) {
      return 'optimism';
    } else if (chainId == ChainIds.METIS) {
      return 'metis';
    } else if (chainId == ChainIds.BNB) {
      return 'binance';
    } else if (chainId == ChainIds.BASE) {
      return 'base';
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return 'polygon_zkevm';
    } else if (chainId == ChainIds.GNOSIS) {
      return 'gnosis';
    } else if (chainId == ChainIds.SCROLL) {
      return 'scroll';
    }

    if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return 'ethereum_sepolia';
    } else if (chainId == TestNetChainIds.ETHEREUM_GOERLI) {
      return 'ethereum_goerli';
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return 'polygon_mumbai';
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return 'avalanche_fuji';
    } else if (chainId == TestNetChainIds.ARBITRUM_GOERLI) {
      return 'arbitrum_goerli';
    } else if (chainId == TestNetChainIds.OPTIMISM_GOERLI) {
      return 'optimism_goerli';
    } else if (chainId == TestNetChainIds.METIS_TESTNET) {
      return 'metis_test';
    } else if (chainId == TestNetChainIds.BNB_TESTNET) {
      return 'binance_test';
    } else if (chainId == TestNetChainIds.BASE_GOERLI) {
      return 'base_goerli';
    } else if (chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI) {
      return 'polygon_zkevm_goerli';
    } else if (chainId == TestNetChainIds.GNOSIS_CHIADO) {
      return 'gnosis_chiado';
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return 'scroll_sepolia';
    } else {
      revert('chain id is not supported');
    }
  }
}
