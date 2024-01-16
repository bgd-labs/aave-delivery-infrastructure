// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {ILayerZeroReceiver} from 'solidity-examples/interfaces/ILayerZeroReceiver.sol';
import {ILayerZeroEndpoint} from 'solidity-examples/interfaces/ILayerZeroEndpoint.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';

import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {ILayerZeroAdapter} from './ILayerZeroAdapter.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {Errors} from '../../libs/Errors.sol';

/**
 * @title LayerZeroAdapter
 * @author BGD Labs
 * @notice LayerZero bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract LayerZeroAdapter is BaseAdapter, ILayerZeroAdapter, ILayerZeroReceiver {
  /// @inheritdoc ILayerZeroAdapter
  uint16 public constant VERSION = 1;
  ILayerZeroEndpoint public immutable LZ_ENDPOINT;

  /**
   * @notice constructor for the Layer Zero adapter
   * @param lzEndpoint address of the layer zero endpoint on the current chain where adapter is deployed
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address lzEndpoint,
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'LayerZero adapter', trustedRemotes) {
    require(lzEndpoint != address(0), Errors.INVALID_LZ_ENDPOINT);
    LZ_ENDPOINT = ILayerZeroEndpoint(lzEndpoint);
  }

  /// @inheritdoc ILayerZeroReceiver
  function lzReceive(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    uint64,
    bytes calldata _payload
  ) external {
    // lzReceive must be called by the endpoint for security
    require(msg.sender == address(LZ_ENDPOINT), Errors.CALLER_NOT_LZ_ENDPOINT);

    uint256 originChainId = nativeToInfraChainId(_srcChainId);
    address trustedRemote = _trustedRemotes[originChainId];
    bytes memory srcBytes = abi.encodePacked(trustedRemote, address(this));

    require(
      trustedRemote != address(0) &&
        _srcAddress.length == srcBytes.length &&
        srcBytes.length > 0 &&
        keccak256(_srcAddress) == keccak256(srcBytes),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(_payload, originChainId);
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    uint16 nativeChainId = SafeCast.toUint16(infraToNativeChainId(destinationChainId));
    require(nativeChainId != uint16(0), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    uint256 totalGasLimit = executionGasLimit + BASE_GAS_LIMIT;

    bytes memory adapterParams = abi.encodePacked(VERSION, totalGasLimit);

    (uint256 nativeFee, ) = LZ_ENDPOINT.estimateFees(
      nativeChainId,
      receiver,
      message,
      false,
      adapterParams
    );

    require(nativeFee <= address(this).balance, Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES);

    uint64 nonce = LZ_ENDPOINT.getOutboundNonce(nativeChainId, address(this));

    // remote address concatenated with local address packed into 40 bytes
    bytes memory remoteAndLocalAddresses = abi.encodePacked(receiver, address(this));

    LZ_ENDPOINT.send{value: nativeFee}(
      nativeChainId,
      remoteAndLocalAddresses,
      message,
      payable(address(this)),
      address(0), // uses native currency for bridge payment
      adapterParams
    );

    return (address(LZ_ENDPOINT), nonce);
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(
    uint256 nativeChainId
  ) public pure virtual override returns (uint256) {
    if (nativeChainId == uint16(101)) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId == uint16(106)) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId == uint16(109)) {
      return ChainIds.POLYGON;
    } else if (nativeChainId == uint16(110)) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId == uint16(111)) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId == uint16(112)) {
      return ChainIds.FANTOM;
    } else if (nativeChainId == uint16(116)) {
      return ChainIds.HARMONY;
    } else if (nativeChainId == uint16(102)) {
      return ChainIds.BNB;
    } else if (nativeChainId == uint16(151)) {
      return ChainIds.METIS;
    } else if (nativeChainId == uint16(145)) {
      return ChainIds.GNOSIS;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(
    uint256 infraChainId
  ) public pure virtual override returns (uint256) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return uint16(101);
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return uint16(106);
    } else if (infraChainId == ChainIds.POLYGON) {
      return uint16(109);
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return uint16(110);
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return uint16(111);
    } else if (infraChainId == ChainIds.FANTOM) {
      return uint16(112);
    } else if (infraChainId == ChainIds.HARMONY) {
      return uint16(116);
    } else if (infraChainId == ChainIds.METIS) {
      return uint16(151);
    } else if (infraChainId == ChainIds.BNB) {
      return uint16(102);
    } else if (infraChainId == ChainIds.GNOSIS) {
      return uint16(145);
    } else {
      return uint16(0);
    }
  }
}
