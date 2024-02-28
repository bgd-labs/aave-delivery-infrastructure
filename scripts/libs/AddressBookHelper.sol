// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscPolygonZkEvm} from 'aave-address-book/MiscPolygonZkEvm.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscMetis} from 'aave-address-book/MiscMetis.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {MiscScroll} from 'aave-address-book/MiscScroll.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {TestNetChainIds} from '../contract_extensions/TestNetChainIds.sol';
import {MiscSepolia} from 'aave-address-book/MiscSepolia.sol';
import {MiscMumbai} from 'aave-address-book/MiscMumbai.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3PolygonZkEvm} from 'aave-address-book/GovernanceV3PolygonZkEvm.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Mumbai} from 'aave-address-book/GovernanceV3Mumbai.sol';
import {GovernanceV3Fuji} from 'aave-address-book/GovernanceV3Fuji.sol';

library AddressBookMiscHelper {
  function getCrossChainController(uint256 chainId) internal pure returns (address) {
    if (chainId == ChainIds.ETHEREUM) {
      return GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.POLYGON) {
      return GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.AVALANCHE) {
      return GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.ARBITRUM) {
      return GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.OPTIMISM) {
      return GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.METIS) {
      return GovernanceV3Metis.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.BNB) {
      return GovernanceV3BNB.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.BASE) {
      return GovernanceV3Base.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return GovernanceV3PolygonZkEvm.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.GNOSIS) {
      return GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == ChainIds.SCROLL) {
      return GovernanceV3Scroll.CROSS_CHAIN_CONTROLLER;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return GovernanceV3Mumbai.CROSS_CHAIN_CONTROLLER;
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return GovernanceV3Fuji.CROSS_CHAIN_CONTROLLER;
    } else {
      return address(0);
    }
  }

  function getTransparentProxyFactory(uint256 chainId) internal pure returns (address) {
    if (chainId == ChainIds.ETHEREUM) {
      return MiscEthereum.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.POLYGON) {
      return MiscPolygon.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.AVALANCHE) {
      return MiscAvalanche.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.ARBITRUM) {
      return MiscArbitrum.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.OPTIMISM) {
      return MiscOptimism.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.METIS) {
      return MiscMetis.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.BNB) {
      return MiscBNB.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.BASE) {
      return MiscBase.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return MiscPolygonZkEvm.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.GNOSIS) {
      return MiscGnosis.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == ChainIds.SCROLL) {
      return MiscScroll.TRANSPARENT_PROXY_FACTORY;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return MiscSepolia.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return MiscMumbai.TRANSPARENT_PROXY_FACTORY;
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return address(0);
    } else {
      return address(0);
    }
  }

  function getProxyAdmin(uint256 chainId) internal pure returns (address) {
    if (chainId == ChainIds.ETHEREUM) {
      return MiscEthereum.PROXY_ADMIN;
    } else if (chainId == ChainIds.POLYGON) {
      return MiscPolygon.PROXY_ADMIN;
    } else if (chainId == ChainIds.AVALANCHE) {
      return MiscAvalanche.PROXY_ADMIN;
    } else if (chainId == ChainIds.ARBITRUM) {
      return MiscArbitrum.PROXY_ADMIN;
    } else if (chainId == ChainIds.OPTIMISM) {
      return MiscOptimism.PROXY_ADMIN;
    } else if (chainId == ChainIds.METIS) {
      return MiscMetis.PROXY_ADMIN;
    } else if (chainId == ChainIds.BNB) {
      return MiscBNB.PROXY_ADMIN;
    } else if (chainId == ChainIds.BASE) {
      return MiscBase.PROXY_ADMIN;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return MiscPolygonZkEvm.PROXY_ADMIN;
    } else if (chainId == ChainIds.GNOSIS) {
      return MiscGnosis.PROXY_ADMIN;
    } else if (chainId == ChainIds.SCROLL) {
      return MiscScroll.PROXY_ADMIN;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return MiscSepolia.PROXY_ADMIN;
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return address(0);
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return address(0);
    } else {
      return address(0);
    }
  }

  function getCreate3Factory(uint256 chainId) internal pure returns (address) {
    if (chainId == ChainIds.ETHEREUM) {
      return MiscEthereum.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.POLYGON) {
      return MiscPolygon.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.AVALANCHE) {
      return MiscAvalanche.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.ARBITRUM) {
      return MiscArbitrum.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.OPTIMISM) {
      return MiscOptimism.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.METIS) {
      return MiscMetis.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.BNB) {
      return MiscBNB.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.BASE) {
      return MiscBase.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return MiscPolygonZkEvm.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.GNOSIS) {
      return MiscGnosis.CREATE_3_FACTORY;
    } else if (chainId == ChainIds.SCROLL) {
      //      return MiscScroll.CREATE_3_FACTORY;
      return address(0);
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return address(0);
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return address(0);
    } else {
      return address(0);
    }
  }

  function getProtocolGuardian(uint256 chainId) internal pure returns (address) {
    if (chainId == ChainIds.ETHEREUM) {
      return MiscEthereum.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.POLYGON) {
      return MiscPolygon.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.AVALANCHE) {
      return MiscAvalanche.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.ARBITRUM) {
      return MiscArbitrum.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.OPTIMISM) {
      return MiscOptimism.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.METIS) {
      return MiscMetis.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.BNB) {
      return MiscBNB.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.BASE) {
      return MiscBase.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      return MiscPolygonZkEvm.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.GNOSIS) {
      return MiscGnosis.PROTOCOL_GUARDIAN;
    } else if (chainId == ChainIds.SCROLL) {
      return MiscScroll.PROTOCOL_GUARDIAN;
    }
    // Testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      return address(0);
    } else if (chainId == TestNetChainIds.POLYGON_MUMBAI) {
      return address(0);
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      return address(0);
    } else {
      return address(0);
    }
  }
}
