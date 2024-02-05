// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import './lib/WormholeChains.sol';
import {IWormholeReceiver} from './interfaces/IWormholeReceiver.sol';
import {IWormholeRelayer} from './interfaces/IWormholeRelayer.sol';
import {IWormholeAdapter} from './IWormholeAdapter.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {Errors} from '../../libs/Errors.sol';

/**
 * @title WormholeAdapter
 * @author BGD Labs
 * @notice Wormhole bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract WormholeAdapter is BaseAdapter, IWormholeAdapter, IWormholeReceiver {
  /// @inheritdoc IWormholeAdapter
  address public immutable WORMHOLE_RELAYER;

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param wormholeRelayer wormhole entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address wormholeRelayer,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, trustedRemotes) {
    require(wormholeRelayer != address(0), Errors.WORMHOLE_RELAYER_CANT_BE_ADDRESS_0);
    WORMHOLE_RELAYER = IWormholeRelayer(wormholeRelayer);
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 destinationGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    uint64 nativeChainId = SafeCast.toUint16(infraToNativeChainId(destinationChainId));
    require(nativeChainId != uint16(0), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    uint256 cost = WORMHOLE_RELAYER.quoteEVMDeliveryPrice(nativeChainId, 0, destinationGasLimit);

    uint64 sequence = WORMHOLE_RELAYER.sendPayloadToEvm{value: cost}(
      nativeChainId,
      receiver,
      message,
      0, // no receiver value needed
      destinationGasLimit
    );

    return (address(WORMHOLE_RELAYER), uint256(sequence));
  }

  /// @inheritdoc IWormholeReceiver
  function receiveWormholeMessages(
    bytes memory payload,
    bytes[] memory,
    bytes32 sourceAddress,
    uint16 sourceChain,
    bytes32
  ) external payable {
    address srcAddress = address(uint160(uint256(data)));

    uint256 originChainId = nativeToInfraChainId(sourceChain);

    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(payload, originChainId);
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    if (nativeChainId == CHAIN_ID_ETHEREUM) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId == CHAIN_ID_AVALANCHE) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId == CHAIN_ID_POLYGON) {
      return ChainIds.POLYGON;
    } else if (nativeChainId == CHAIN_ID_ARBITRUM) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId == CHAIN_ID_OPTIMISM) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId == CHAIN_ID_FANTOM) {
      return ChainIds.FANTOM;
    } else if (nativeChainId == CHAIN_ID_BSC) {
      return ChainIds.BNB;
    } else if (nativeChainId == CHAIN_ID_GNOSIS) {
      return ChainIds.GNOSIS;
    } else if (nativeChainId == CHAIN_ID_CELO) {
      return ChainIds.CELO;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return CHAIN_ID_ETHEREUM;
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return CHAIN_ID_AVALANCHE;
    } else if (infraChainId == ChainIds.POLYGON) {
      return CHAIN_ID_POLYGON;
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return CHAIN_ID_ARBITRUM;
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return CHAIN_ID_OPTIMISM;
    } else if (infraChainId == ChainIds.FANTOM) {
      return CHAIN_ID_FANTOM;
    } else if (infraChainId == ChainIds.BNB) {
      return CHAIN_ID_BSC;
    } else if (infraChainId == ChainIds.GNOSIS) {
      return CHAIN_ID_GNOSIS;
    } else if (infraChainId == ChainIds.CELO) {
      return CHAIN_ID_CELO;
    } else {
      return uint16(0);
    }
  }
}
