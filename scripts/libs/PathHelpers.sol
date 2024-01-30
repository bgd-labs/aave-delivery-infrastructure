// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TestNetChainIds} from '../contract_extensions/TestNetChainIds.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';

library StringUtils {
  function eq(string memory a, string memory b) internal pure returns (bool) {
    return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
  }

  function strToUint(string memory _str) internal pure returns (uint256 res, bool err) {
    for (uint256 i = 0; i < bytes(_str).length; i++) {
      if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
        return (0, true);
      }
      res += (uint8(bytes(_str)[i]) - 48) * 10 ** (bytes(_str).length - i - 1);
    }

    return (res, false);
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
    string memory networkName = string.concat('_', getChainNameById(chainId));
    string memory networkWithRevision = string.concat(revision, networkName);
    string memory path = string.concat('./deployments/revisions/', networkWithRevision);
    return string.concat(path, '.json');
  }

  function getChainIdByName(string memory networkName) internal pure returns (uint256) {
    if (networkName.eq('ethereum')) {
      return ChainIds.ETHEREUM;
    } else if (networkName.eq('polygon')) {
      return ChainIds.POLYGON;
    } else if (networkName.eq('avalanche')) {
      return ChainIds.AVALANCHE;
    } else if (networkName.eq('arbitrum')) {
      return ChainIds.ARBITRUM;
    } else if (networkName.eq('optimism')) {
      return ChainIds.OPTIMISM;
    } else if (networkName.eq('metis')) {
      return ChainIds.METIS;
    } else if (networkName.eq('binance')) {
      return ChainIds.BNB;
    } else if (networkName.eq('base')) {
      return ChainIds.BASE;
    } else if (networkName.eq('gnosis')) {
      return ChainIds.GNOSIS;
    } else if (networkName.eq('scroll')) {
      return ChainIds.SCROLL;
    } else if (networkName.eq('polygon_zkevm')) {
      return ChainIds.POLYGON_ZK_EVM;
    }

    if (networkName.eq('ethereum_sepolia')) {
      return TestNetChainIds.ETHEREUM_SEPOLIA;
    } else if (networkName.eq('polygon_mumbai')) {
      return TestNetChainIds.POLYGON_MUMBAI;
    } else if (networkName.eq('avalanche_fuji')) {
      return TestNetChainIds.AVALANCHE_FUJI;
    } else {
      revert('chain not accepted');
    }
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

  function isTestNet(uint256 chainId) internal pure returns (bool) {
    if (
      chainId == TestNetChainIds.ETHEREUM_SEPOLIA ||
      chainId == TestNetChainIds.ETHEREUM_GOERLI ||
      chainId == TestNetChainIds.POLYGON_MUMBAI ||
      chainId == TestNetChainIds.AVALANCHE_FUJI ||
      chainId == TestNetChainIds.ARBITRUM_GOERLI ||
      chainId == TestNetChainIds.OPTIMISM_GOERLI ||
      chainId == TestNetChainIds.METIS_TESTNET ||
      chainId == TestNetChainIds.BNB_TESTNET ||
      chainId == TestNetChainIds.BASE_GOERLI ||
      chainId == TestNetChainIds.POLYGON_ZK_EVM_GOERLI ||
      chainId == TestNetChainIds.GNOSIS_CHIADO ||
      chainId == TestNetChainIds.SCROLL_SEPOLIA
    ) {
      return true;
    } else {
      return false;
    }
  }
}
