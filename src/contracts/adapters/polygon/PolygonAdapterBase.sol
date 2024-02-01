// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {IPolygonAdapter} from './IPolygonAdapter.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {IFxMessageProcessor} from './interfaces/IFxMessageProcessor.sol';
import {IFxTunnel} from './tunnel/interfaces/IFxTunnel.sol';

/**
 * @title PolygonAdapter
 * @author BGD Labs
 * @notice Polygon bridge adapter. Used to send and receive messages cross chain between Ethereum and Polygon
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
abstract contract PolygonAdapterBase is IPolygonAdapter, IFxMessageProcessor, BaseAdapter {
  address public immutable override FX_TUNNEL;

  modifier onlyFxTunnel() {
    require(msg.sender == FX_TUNNEL, Errors.CALLER_NOT_FX_TUNNEL);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param fxTunnel address of the fx tunnel that will be used to send/receive messages to the root/child chain
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address fxTunnel,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Polygon native adapter', trustedRemotes) {
    FX_TUNNEL = fxTunnel;
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    IFxTunnel(FX_TUNNEL).sendMessage(receiver, message);

    return (FX_TUNNEL, 0);
  }

  function processMessage(
    address originalSender,
    bytes calldata message
  ) external override onlyFxTunnel {
    uint256 originChainId = getOriginChainId();
    require(
      _trustedRemotes[originChainId] == originalSender && originalSender != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originChainId);
  }

  /// @inheritdoc IPolygonAdapter
  function getOriginChainId() public view virtual returns (uint256);

  /// @inheritdoc IPolygonAdapter
  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool);

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }
}
