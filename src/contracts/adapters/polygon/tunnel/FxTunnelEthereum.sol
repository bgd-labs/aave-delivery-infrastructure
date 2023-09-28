// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseRootTunnel} from 'fx-portal/tunnel/FxBaseRootTunnel.sol';
import {IFxMessageProcessor} from '../interfaces/IFxMessageProcessor.sol';
import {IFxTunnel} from './interfaces/IFxTunnel.sol';

/**
 * @title FxTunnelEthereum
 * @author BGD Labs
 * @notice The Ethereum FxTunnel implementation for arbitrary two-way message passing
 * between Polygon and Ethereum.
 */
contract FxTunnelEthereum is FxBaseRootTunnel, IFxTunnel {
  constructor(
    address _checkpointManager,
    address _fxRoot,
    address _fxTunnelPolygon
  ) FxBaseRootTunnel(_checkpointManager, _fxRoot) {
    require(_fxTunnelPolygon != address(0), 'FxTunnelEthereum: child tunnel can not be zero');
    fxChildTunnel = _fxTunnelPolygon;
  }

  /// @inheritdoc IFxTunnel
  function sendMessage(address receiver, bytes calldata message) external override {
    // Since the fxRoot will encode the sender as this bridge, we encode the original sender here.
    bytes memory encodedMessage = abi.encode(msg.sender, receiver, message);
    _sendMessageToChild(encodedMessage);
  }

  function _processMessageFromChild(bytes memory message) internal override {
    // This function is only called after the transaction has been proven and the sender verified to be
    // the fxTunnelPolygon.
    // Extract the original sender, receiver and message from the encoded message
    (address originSender, address receiver, bytes memory decodedMessage) = abi.decode(
      message,
      (address, address, bytes)
    );
    IFxMessageProcessor(receiver).processMessage(originSender, decodedMessage);
  }
}
