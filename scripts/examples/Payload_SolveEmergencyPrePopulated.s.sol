// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainControllerWithEmergencyMode} from '../../src/contracts/interfaces/ICrossChainControllerWithEmergencyMode.sol';

/// @dev Remember to set this before running the deployment script.
address constant CROSS_CHAIN_CONTROLLER = address(0);

/**
 * @notice Deploys a payload with a single function that solves the emergency using pre-populated default data.
 *
 * @dev Note that this should only be used to create the calldata necessary to pass to the
 * controller, as the Guardian must solve the emergency, not governance.
 *
 * Remember to set the correct controller address above.
 *
 * This payload does the following on all chains:
 * 1. Sets the validity timestamp to block.timestamp
 * 2. Disallows all receiver bridge adapters
 * 3. Disables all forwarder bridge adapters
 *
 * Run with:
 * forge script scripts/create_payloads/Payload_SolveEmergencyPrePopulated.s.sol --tc CreateSolveEmergencyPayloadPrePopulated
 */
contract SolveEmergencyPayloadPrePopulated {
  ICrossChainControllerWithEmergencyMode immutable CONTROLLER;

  uint256 constant CHAIN_IDS_COUNT = 9;

  constructor(address _controller) {
    CONTROLLER = ICrossChainControllerWithEmergencyMode(_controller);
  }

  function execute() external {
    uint256[CHAIN_IDS_COUNT] memory chainIds = _chainIds();

    /* --------------------------- Receiver Parameters -------------------------- */
    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationInputs = new ICrossChainReceiver.ConfirmationInput[](0);

    ICrossChainReceiver.ValidityTimestampInput[] // block.timestamp
      memory validityTimestampInputs = _getValidityTimestamps(chainIds);

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        0
      );

    // Disallow all adapters on all chains.
    (
      address[][CHAIN_IDS_COUNT] memory receiverBridgeAdaptersPerChain,
      uint256 receiverMaxAdapterCount
    ) = _getReceiverBridgeAdaptersAndMaxCountPerChain(chainIds);

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToDisallow = _getUniqueAdapters(
        chainIds,
        receiverBridgeAdaptersPerChain,
        receiverMaxAdapterCount
      );

    /* -------------------------- Forwarder Parameters -------------------------- */

    address[] memory sendersToApprove = new address[](0);
    address[] memory sendersToRemove = new address[](0);

    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        0
      );

    (
      address[][CHAIN_IDS_COUNT] memory forwarderBridgeAdaptersPerChain,
      uint256 forwarderMaxAdapterCount
    ) = _getForwarderBridgeAdaptersAndMaxCountPerChain(chainIds);

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarderBridgeAdaptersToDisable = _castToForwarderBridgeAdaptersToDisable(
        _getUniqueAdapters(chainIds, forwarderBridgeAdaptersPerChain, forwarderMaxAdapterCount)
      );

    ICrossChainForwarder.OptimalBandwidthByChain[]
      memory optimalBandwidthByChain = new ICrossChainForwarder.OptimalBandwidthByChain[](0);

    CONTROLLER.solveEmergency(
      confirmationInputs,
      validityTimestampInputs,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable,
      optimalBandwidthByChain
    );
  }

  function _getReceiverBridgeAdaptersAndMaxCountPerChain(
    uint256[CHAIN_IDS_COUNT] memory chainIds
  ) internal view returns (address[][CHAIN_IDS_COUNT] memory, uint256) {
    address[][CHAIN_IDS_COUNT] memory bridgeAdaptersPerChain;
    uint256 maxAdapterCount;
    for (uint256 i = 0; i < CHAIN_IDS_COUNT; ++i) {
      bridgeAdaptersPerChain[i] = CONTROLLER.getReceiverBridgeAdaptersByChain(chainIds[i]);
      maxAdapterCount += bridgeAdaptersPerChain[i].length;
    }
    return (bridgeAdaptersPerChain, maxAdapterCount);
  }

  function _getForwarderBridgeAdaptersAndMaxCountPerChain(
    uint256[CHAIN_IDS_COUNT] memory chainIds
  ) internal view returns (address[][CHAIN_IDS_COUNT] memory, uint256) {
    address[][CHAIN_IDS_COUNT] memory bridgeAdaptersPerChain;
    uint256 maxAdapterCount;
    for (uint256 i = 0; i < CHAIN_IDS_COUNT; ++i) {
      ICrossChainForwarder.ChainIdBridgeConfig[] memory chainIdBridgeConfigs = CONTROLLER
        .getForwarderBridgeAdaptersByChain(chainIds[i]);

      bridgeAdaptersPerChain[i] = new address[](chainIdBridgeConfigs.length);

      // Populate the bridge adapters per chain array
      for (uint256 j = 0; j < chainIdBridgeConfigs.length; ++j) {
        bridgeAdaptersPerChain[i][j] = chainIdBridgeConfigs[j].currentChainBridgeAdapter;
      }
      maxAdapterCount += bridgeAdaptersPerChain[i].length;
    }
    return (bridgeAdaptersPerChain, maxAdapterCount);
  }

  function _getValidityTimestamps(
    uint256[CHAIN_IDS_COUNT] memory chainIds
  ) internal view returns (ICrossChainReceiver.ValidityTimestampInput[] memory) {
    ICrossChainReceiver.ValidityTimestampInput[]
      memory validityTimestampInputs = new ICrossChainReceiver.ValidityTimestampInput[](
        CHAIN_IDS_COUNT
      );
    for (uint256 i = 0; i < CHAIN_IDS_COUNT; ++i) {
      validityTimestampInputs[i] = ICrossChainReceiver.ValidityTimestampInput({
        chainId: chainIds[i],
        validityTimestamp: uint120(block.timestamp)
      });
    }
    return validityTimestampInputs;
  }

  function _getUniqueAdapters(
    uint256[CHAIN_IDS_COUNT] memory chainIds,
    address[][CHAIN_IDS_COUNT] memory bridgeAdaptersPerChain,
    uint256 maxAdapterCount
  ) internal pure returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory) {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory uniqueAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        maxAdapterCount
      );
    uint256 realAdapterCount;

    for (uint256 i = 0; i < CHAIN_IDS_COUNT; ++i) {
      for (uint256 j = 0; j < bridgeAdaptersPerChain[i].length; ++j) {
        if (!_adapterExistsInArray(bridgeAdaptersPerChain[i][j], uniqueAdapters)) {
          uniqueAdapters[realAdapterCount].bridgeAdapter = bridgeAdaptersPerChain[i][j];
          uniqueAdapters[realAdapterCount].chainIds = _getAdapterChainIds(
            bridgeAdaptersPerChain[i][j],
            chainIds,
            bridgeAdaptersPerChain
          );
          ++realAdapterCount;
        }
      }
    }

    return _trimAdapterArray(uniqueAdapters, realAdapterCount);
  }

  function _getAdapterChainIds(
    address adapter,
    uint256[CHAIN_IDS_COUNT] memory chainIds,
    address[][CHAIN_IDS_COUNT] memory bridgeAdaptersPerChain
  ) internal pure returns (uint256[] memory) {
    uint256[] memory uniqueChainIds = new uint256[](CHAIN_IDS_COUNT);
    uint256 realChainIdsCount;

    for (uint256 i = 0; i < CHAIN_IDS_COUNT; ++i) {
      for (uint256 j = 0; j < bridgeAdaptersPerChain[i].length; ++j) {
        if (bridgeAdaptersPerChain[i][j] == adapter) {
          uniqueChainIds[realChainIdsCount] = chainIds[i];
          ++realChainIdsCount;
          break;
        }
      }
    }

    return _trimChainIdArray(uniqueChainIds, realChainIdsCount);
  }

  function _castToForwarderBridgeAdaptersToDisable(
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory input
  ) internal pure returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory) {
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory output = new ICrossChainForwarder.BridgeAdapterToDisable[](input.length);
    for (uint256 i = 0; i < input.length; ++i) {
      output[i].bridgeAdapter = input[i].bridgeAdapter;
      output[i].chainIds = input[i].chainIds;
    }
    return output;
  }

  function _chainIds() internal pure returns (uint256[CHAIN_IDS_COUNT] memory) {
    uint256[CHAIN_IDS_COUNT] memory chainIds;
    chainIds[0] = ChainIds.ETHEREUM;
    chainIds[1] = ChainIds.POLYGON;
    chainIds[2] = ChainIds.AVALANCHE;
    chainIds[3] = ChainIds.ARBITRUM;
    chainIds[4] = ChainIds.OPTIMISM;
    chainIds[5] = ChainIds.FANTOM;
    chainIds[6] = ChainIds.HARMONY;
    chainIds[7] = ChainIds.METIS;
    chainIds[8] = ChainIds.BNB;
    return chainIds;
  }

  function _adapterExistsInArray(
    address adapter,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory array
  ) internal pure returns (bool) {
    for (uint256 i = 0; i < array.length; ++i) {
      if (array[i].bridgeAdapter == adapter) {
        return true;
      }
    }
    return false;
  }

  function _trimAdapterArray(
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory input,
    uint256 length
  ) internal pure returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory) {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory output = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](length);
    for (uint256 i = 0; i < length; ++i) {
      output[i] = input[i];
    }
    return output;
  }

  function _trimChainIdArray(
    uint256[] memory input,
    uint256 length
  ) internal pure returns (uint256[] memory) {
    uint256[] memory output = new uint256[](length);
    for (uint256 i = 0; i < length; ++i) {
      output[i] = input[i];
    }
    return output;
  }
}

contract CreateSolveEmergencyPayloadPrePopulated is Script {
  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    SolveEmergencyPayloadPrePopulated solveEmergencyPayloadPrePopulated = new SolveEmergencyPayloadPrePopulated(
        CROSS_CHAIN_CONTROLLER
      );
    console2.log(
      'SolveEmergencyPayloadPrePopulated deployed at %s on chain with chain ID %s',
      address(solveEmergencyPayloadPrePopulated),
      block.chainid
    );
    vm.stopBroadcast();
  }
}
