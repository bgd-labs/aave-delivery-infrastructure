// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import '../contract_extensions/MockDestination.sol';

abstract contract BaseMockDestination is BaseScript {
  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    addresses.mockDestination = address(new MockDestination(addresses.crossChainController));
  }
}

contract Ethereum is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Avalanche is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Optimism is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Metis is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Base is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Binance is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Zkevm is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }
}

contract Celo is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Scroll is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Ethereum_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Arbitrum_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ARBITRUM_GOERLI;
  }
}

contract Avalanche_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Optimism_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }
}

contract Polygon_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Metis_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }
}

contract Binance_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}

contract Base_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BASE_GOERLI;
  }
}

contract Scroll_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.SCROLL_SEPOLIA;
  }
}

contract Celo_testnet is BaseMockDestination {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }
}
