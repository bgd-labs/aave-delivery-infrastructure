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
   * @param originConfigs array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address lzEndpoint,
    address crossChainController,
    TrustedRemotesConfig[] memory originConfigs
  ) BaseAdapter(crossChainController, originConfigs) {
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
    uint256 destinationGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    uint16 nativeChainId = SafeCast.toUint16(infraToNativeChainId(destinationChainId));
    require(nativeChainId != uint16(0), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    bytes memory adapterParams = abi.encodePacked(VERSION, destinationGasLimit);

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
    if (nativeChainId == 101) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId == 106) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId == 109) {
      return ChainIds.POLYGON;
    } else if (nativeChainId == 110) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId == 111) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId == 112) {
      return ChainIds.FANTOM;
    } else if (nativeChainId == 116) {
      return ChainIds.HARMONY;
    } else if (nativeChainId == 102) {
      return ChainIds.BNB;
    } else if (nativeChainId == 151) {
      return ChainIds.METIS;
    } else if (nativeChainId == 145) {
      return ChainIds.GNOSIS;
    } else if (nativeChainId == 125) {
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
      return 101;
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return 106;
    } else if (infraChainId == ChainIds.POLYGON) {
      return 109;
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return 110;
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return 111;
    } else if (infraChainId == ChainIds.FANTOM) {
      return 112;
    } else if (infraChainId == ChainIds.HARMONY) {
      return 116;
    } else if (infraChainId == ChainIds.METIS) {
      return 151;
    } else if (infraChainId == ChainIds.BNB) {
      return 102;
    } else if (infraChainId == ChainIds.GNOSIS) {
      return 145;
    } else if (infraChainId == ChainIds.CELO) {
      return 125;
    } else {
      return 0;
    }
  }
}
