// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {IWormholeReceiver} from './interfaces/IWormholeReceiver.sol';
import {IWormholeRelayer} from './interfaces/IWormholeRelayer.sol';
import {IWormholeAdapter} from './IWormholeAdapter.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from '../../libs/ChainIds.sol';

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

  /// @inheritdoc IWormholeAdapter
  address public immutable REFUND_ADDRESS;

  /**
   * @notice only calls from the set relayer are accepted.
   */
  modifier onlyRelayer() {
    require(msg.sender == WORMHOLE_RELAYER, Errors.CALLER_NOT_WORMHOLE_RELAYER);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param wormholeRelayer wormhole entry point address
   * @param refundAddress address that will receive left over gas
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address wormholeRelayer,
    address refundAddress,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, trustedRemotes) {
    require(wormholeRelayer != address(0), Errors.WORMHOLE_RELAYER_CANT_BE_ADDRESS_0);
    WORMHOLE_RELAYER = wormholeRelayer;
    REFUND_ADDRESS = refundAddress;
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 destinationGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    uint16 nativeChainId = SafeCast.toUint16(infraToNativeChainId(destinationChainId));
    require(nativeChainId != uint16(0), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    uint64 sequence = IWormholeRelayer(WORMHOLE_RELAYER).sendPayloadToEvm{
      value: _getGasCost(destinationGasLimit, nativeChainId)
    }(
      nativeChainId,
      receiver,
      message,
      0, // no receiver value needed
      destinationGasLimit,
      nativeChainId,
      REFUND_ADDRESS
    );

    return (address(WORMHOLE_RELAYER), uint256(sequence));
  }

  /// @inheritdoc IWormholeReceiver
  function receiveWormholeMessages(
    bytes calldata payload, // TODO: does it affect?? if in interface its as memory??
    bytes[] memory,
    bytes32 sourceAddress,
    uint16 sourceChain,
    bytes32
  ) external payable onlyRelayer {
    address srcAddress = address(uint160(uint256(sourceAddress)));

    uint256 originChainId = nativeToInfraChainId(sourceChain);

    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(payload, originChainId);
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(
    uint256 nativeChainId
  ) public pure virtual override returns (uint256) {
    if (nativeChainId == uint16(2)) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId == uint16(6)) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId == uint16(5)) {
      return ChainIds.POLYGON;
    } else if (nativeChainId == uint16(23)) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId == uint16(24)) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId == uint16(10)) {
      return ChainIds.FANTOM;
    } else if (nativeChainId == uint16(4)) {
      return ChainIds.BNB;
    } else if (nativeChainId == uint16(25)) {
      return ChainIds.GNOSIS;
    } else if (nativeChainId == uint16(14)) {
      return ChainIds.CELO;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(
    uint256 infraChainId
  ) public pure virtual override returns (uint256) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return uint16(2);
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return uint16(6);
    } else if (infraChainId == ChainIds.POLYGON) {
      return uint16(5);
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return uint16(23);
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return uint16(24);
    } else if (infraChainId == ChainIds.FANTOM) {
      return uint16(10);
    } else if (infraChainId == ChainIds.BNB) {
      return uint16(4);
    } else if (infraChainId == ChainIds.GNOSIS) {
      return uint16(25);
    } else if (infraChainId == ChainIds.CELO) {
      return uint16(14);
    } else {
      return uint16(0);
    }
  }

  /**
   * @notice method to get the amount to pay for destination chain delivery
   * @return value in eth
   */
  function _getGasCost(uint256 gasLimit, uint16 destinationChain) internal view returns (uint256) {
    (uint256 cost, ) = IWormholeRelayer(WORMHOLE_RELAYER).quoteEVMDeliveryPrice(
      destinationChain,
      0,
      gasLimit
    );
    return cost;
  }
}
