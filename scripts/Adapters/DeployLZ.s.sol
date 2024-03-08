// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LayerZeroAdapter, ILayerZeroAdapter, IBaseAdapter} from '../../src/contracts/adapters/layerZero/LayerZeroAdapter.sol';
import {LayerZeroAdapterTestnet} from '../contract_extensions/LayerZeroAdapter.sol';
import '../BaseScript.sol';
import './BaseAdapterScript.sol';

abstract contract BaseLZAdapter is BaseAdapterScript {
  function LZ_ENDPOINT() public view virtual returns (address);

  function isTestNet() public view virtual returns (bool);

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    address lzAdapter;
    if (isTestNet()) {
      lzAdapter = address(
        new LayerZeroAdapterTestnet(
          LZ_ENDPOINT(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    } else {
      lzAdapter = address(
        new LayerZeroAdapter(
          LZ_ENDPOINT(),
          addresses.crossChainController,
          GET_BASE_GAS_LIMIT(),
          trustedRemotes
        )
      );
    }
    addresses.lzAdapter = lzAdapter;
  }
}

contract Ethereum is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);
    remoteNetworks[0] = ChainIds.POLYGON;
    remoteNetworks[1] = ChainIds.AVALANCHE;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Ethereum_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](2);
    remoteNetworks[0] = TestNetChainIds.POLYGON_MUMBAI;
    remoteNetworks[1] = TestNetChainIds.AVALANCHE_FUJI;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Avalanche is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Avalanche_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Polygon is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Polygon_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Binance is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.BNB;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Binance_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Gnosis is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Gnosis_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_GOERLI;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}

contract Celo is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = ChainIds.ETHEREUM;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return false;
  }
}

contract Celo_testnet is BaseLZAdapter {
  function LZ_ENDPOINT() public pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }

  function REMOTE_NETWORKS() public pure override returns (uint256[] memory) {
    uint256[] memory remoteNetworks = new uint256[](1);
    remoteNetworks[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    return remoteNetworks;
  }

  function isTestNet() public pure override returns (bool) {
    return true;
  }
}
