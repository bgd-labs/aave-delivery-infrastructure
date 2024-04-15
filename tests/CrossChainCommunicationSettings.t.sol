// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Binance} from 'aave-address-book/GovernanceV3Binance.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {ICrossChainForwarder} from '../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from '../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';
import {BaseAdapter} from '../src/contracts/adapters/BaseAdapter.sol';

contract BaseCCCommunicationTest is Test {
  uint256 public ethFork;
  uint256 public avaxFork;
  uint256 public polFork;
  uint256 public opFork;
  uint256 public arbFork;
  uint256 public bnbFork;
  uint256 public baseFork;
  uint256 public metisFork;

  function setUp() public {
    ethFork = vm.createFork('ethereum');
    avaxFork = vm.createFork('avalanche');
    polFork = vm.createFork('polygon');
    arbFork = vm.createFork('arbitrum');
    metisFork = vm.createFork('metis');
    opFork = vm.createFork('optimism');
    bnbFork = vm.createFork('binance');
    baseFork = vm.createFork('base');
  }

  function _checkPath(
    address originCrossChainController,
    address destinationCrossChainController,
    uint256 originChainId,
    uint256 destinationChainId,
    uint256 originFork,
    uint256 destinationFork
  ) internal {
    // have to initiate length as it doesnt let me push. If length changes require should change also
    address[] memory originForwarderAdapters;
    address[] memory originDestinationAdapters;
    address[] memory destinationReceiverAdapters;

    vm.selectFork(originFork);
    // get all bridge adapters configurations (current chain and destination chain) that are configured for destination chain
    ICrossChainForwarder.ChainIdBridgeConfig[] memory adaptersByChain = ICrossChainForwarder(
      originCrossChainController
    ).getForwarderBridgeAdaptersByChain(destinationChainId);

    originForwarderAdapters = new address[](adaptersByChain.length);
    originDestinationAdapters = new address[](adaptersByChain.length);

    for (uint256 i = 0; i < adaptersByChain.length; i++) {
      originForwarderAdapters[i] = adaptersByChain[i].currentChainBridgeAdapter;
      originDestinationAdapters[i] = adaptersByChain[i].destinationBridgeAdapter;
    }

    vm.selectFork(destinationFork);
    // get all bridge adapters that are set to receive messages from origin chain
    destinationReceiverAdapters = ICrossChainReceiver(destinationCrossChainController)
      .getReceiverBridgeAdaptersByChain(originChainId);

    // there should be the same amount of bridge adapters that send messages from origin and receive messages at destination
    assertEq(destinationReceiverAdapters.length, originDestinationAdapters.length);

    // there should be enough receiver bridge adapters on destination to reach required confirmations (when on working state)
    require(
      destinationReceiverAdapters.length >=
        ICrossChainReceiver(destinationCrossChainController)
          .getConfigurationByChain(originChainId)
          .requiredConfirmation
    );

    for (uint256 i = 0; i < destinationReceiverAdapters.length; i++) {
      // bridge adapter on destination chain can only receive messages from origin CrossChainController
      assertEq(
        BaseAdapter(destinationReceiverAdapters[i]).getTrustedRemoteByChainId(originChainId),
        originCrossChainController
      );

      // the destination bridge adapters configured on origin must be the same as the ones set on receiving destination.
      // all of them must be set on destination
      bool adapterFound;
      for (uint256 j = 0; j < originDestinationAdapters.length; j++) {
        if (originDestinationAdapters[j] == destinationReceiverAdapters[i]) {
          adapterFound = true;
          break;
        }
      }
      assertEq(adapterFound, true);
    }
  }
}

// contract CrossChainCommunicationSettingsTest is BaseCCCommunicationTest {
//   function test_Eth_Eth_Path() public {
//     vm.selectFork(ethFork);
//     // get bridge adapters configured for the same chain path
//     ICrossChainForwarder.ChainIdBridgeConfig[] memory adaptersByChain = ICrossChainForwarder(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER
//     ).getForwarderBridgeAdaptersByChain(ChainIds.ETHEREUM);

//     // there should only be one bridge adapter configured for same chain path
//     assertEq(adaptersByChain.length, 1);

//     // for same chain path, origin and destination bridge adapter must be the same.
//     assertEq(
//       adaptersByChain[0].currentChainBridgeAdapter,
//       adaptersByChain[0].destinationBridgeAdapter
//     );

//     // same chain bridge adapter has no trusted remotes, as communication is direct (it only forwards messages)
//     assertEq(
//       BaseAdapter(adaptersByChain[0].currentChainBridgeAdapter).getTrustedRemoteByChainId(
//         ChainIds.ETHEREUM
//       ),
//       address(0)
//     );
//   }

//   function test_Eth_Pol_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.POLYGON,
//       ethFork,
//       polFork
//     );
//   }

//   function test_Pol_Eth_Path() public {
//     _checkPath(
//       GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       ChainIds.POLYGON,
//       ChainIds.ETHEREUM,
//       polFork,
//       ethFork
//     );
//   }

//   function test_Eth_Avax_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.AVALANCHE,
//       ethFork,
//       avaxFork
//     );
//   }

//   function test_Avax_Eth_Path() public {
//     _checkPath(
//       GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       ChainIds.AVALANCHE,
//       ChainIds.ETHEREUM,
//       avaxFork,
//       ethFork
//     );
//   }

//   function test_Eth_Op_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.OPTIMISM,
//       ethFork,
//       opFork
//     );
//   }

//   function test_Eth_Arb_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.ARBITRUM,
//       ethFork,
//       arbFork
//     );
//   }

//   function test_Eth_Base_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Base.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.BASE,
//       ethFork,
//       baseFork
//     );
//   }

//   function test_Eth_BNB_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Binance.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.BNB,
//       ethFork,
//       bnbFork
//     );
//   }

//   function test_Eth_Metis_Path() public {
//     _checkPath(
//       GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
//       GovernanceV3Metis.CROSS_CHAIN_CONTROLLER,
//       ChainIds.ETHEREUM,
//       ChainIds.METIS,
//       ethFork,
//       metisFork
//     );
//   }
// }
