// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FxBaseChildTunnel} from 'fx-portal/tunnel/FxBaseChildTunnel.sol';
import {IFxMessageProcessor} from '../interfaces/IFxMessageProcessor.sol';
import {IFxTunnel} from './interfaces/IFxTunnel.sol';

/**
 * @title FxTunnelPolygon
 * @author BGD Labs
 * @notice The Polygon FxTunnel implementation for arbitrary two-way message passing
 * between Polygon and Ethereum.
 */
contract FxTunnelPolygon is FxBaseChildTunnel, IFxTunnel {
  constructor(address _fxChild, address _fxTunnelEthereum) FxBaseChildTunnel(_fxChild) {
    require(_fxTunnelEthereum != address(0), 'FxTunnelPolygon: root tunnel can not be zero');
    fxRootTunnel = _fxTunnelEthereum;
  }

  /// @inheritdoc IFxTunnel
  function sendMessage(address receiver, bytes calldata message) external override {
    bytes memory encodedMessage = abi.encode(msg.sender, receiver, message);
    _sendMessageToRoot(encodedMessage);
  }

  function _processMessageFromRoot(
    uint256,
    address sender,
    bytes memory message
  ) internal override validateSender(sender) {
    // The validateSender(sender) modifier above ensures the `sender` is the fxTunnelEthereum.
    // Extract the original sender, receiver and message from the encoded message
    (address originSender, address receiver, bytes memory decodedMessage) = abi.decode(
      message,
      (address, address, bytes)
    );
    IFxMessageProcessor(receiver).processMessage(originSender, decodedMessage);
  }
}
