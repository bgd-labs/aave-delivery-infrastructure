// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Origin} from './interfaces/ILayerZeroEndpointV2.sol';

interface ILayerZeroReceiver {
  /**
   * @dev Entry point for receiving messages or packets from the endpoint.
   * @param _origin The origin information containing the source endpoint and sender address.
   *  - srcEid: The source chain endpoint ID.
   *  - sender: The sender address on the src chain.
   *  - nonce: The nonce of the message.
   * @param _guid The unique identifier for the received LayerZero message.
   * @param _message The payload of the received message.
   * @param _executor The address of the executor for the received message.
   * @param _extraData Additional arbitrary data provided by the corresponding executor.
   *
   * @dev Entry point for receiving msg/packet from the LayerZero endpoint.
   */
  function lzReceive(
    Origin calldata _origin,
    bytes32 _guid,
    bytes calldata _message,
    address _executor,
    bytes calldata _extraData
  ) external payable {
    // Ensures that only the endpoint can attempt to lzReceive() messages to this OApp.
    if (address(endpoint) != msg.sender) revert OnlyEndpoint(msg.sender);

    // Ensure that the sender matches the expected peer for the source endpoint.
    if (_getPeerOrRevert(_origin.srcEid) != _origin.sender)
      revert OnlyPeer(_origin.srcEid, _origin.sender);

    // Call the internal OApp implementation of lzReceive.
    _lzReceive(_origin, _guid, _message, _executor, _extraData);
  }
}
