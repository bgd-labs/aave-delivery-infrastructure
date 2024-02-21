// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

abstract contract BaseSetCCRAdapters is BaseScript {
  function getChainIds() public virtual returns (uint256[] memory);

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public view virtual returns (address[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    uint256[] memory chainIds = getChainIds();
    address[] memory receiverBridgeAdaptersToAllow = getReceiverBridgeAdaptersToAllow(addresses);

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapterConfig = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        receiverBridgeAdaptersToAllow.length
      );
    for (uint256 i = 0; i < receiverBridgeAdaptersToAllow.length; i++) {
      bridgeAdapterConfig[i] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: receiverBridgeAdaptersToAllow[i],
        chainIds: chainIds
      });
    }

    ICrossChainReceiver(addresses.crossChainController).allowReceiverBridgeAdapters(
      bridgeAdapterConfig
    );
  }
}

contract Ethereum is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](2);
    chainIds[0] = ChainIds.POLYGON;
    chainIds[1] = ChainIds.AVALANCHE;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](4);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[3] = addresses.polAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Polygon is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](4);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[3] = addresses.polAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Avalanche is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Optimism is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.opAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Arbitrum is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.arbAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Metis is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.metisAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Binance is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Base is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.baseAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Gnosis is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.gnosisAdapter;
    //    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Zkevm is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.zkevmAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Scroll is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.SCROLL;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.scrollAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Celo is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.CELO;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.wormholeAdapter;
    //    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Ethereum_testnet is Ethereum {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getChainIds() public pure override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](3);
    chainIds[0] = TestNetChainIds.POLYGON_MUMBAI;
    chainIds[1] = TestNetChainIds.AVALANCHE_FUJI;
    chainIds[2] = TestNetChainIds.BNB_TESTNET;

    return chainIds;
  }
}

contract Polygon_testnet is Polygon {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }

  //  function getReceiverBridgeAdaptersToAllow(
  //    DeployerHelpers.Addresses memory addresses
  //  ) public pure override returns (address[] memory) {
  //    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
  //    //    receiverBridgeAdaptersToAllow[0] = addresses.polAdapter;
  //    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
  //    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
  //    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;
  //
  //    return receiverBridgeAdaptersToAllow;
  //  }
}

contract Avalanche_testnet is Avalanche {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }
}

contract Optimism_testnet is Optimism {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return chainIds;
  }
}

contract Arbitrum_testnet is Arbitrum {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ARBITRUM_GOERLI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return chainIds;
  }
}

contract Metis_testnet is Metis {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return chainIds;
  }
}

contract Binance_testnet is Binance {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }
}

contract Base_testnet is Base {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BASE_GOERLI;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return chainIds;
  }
}

contract Gnosis_testnet is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.gnosisAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Celo_testnet is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    DeployerHelpers.Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.wormholeAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}
