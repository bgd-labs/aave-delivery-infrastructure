// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Origin} from './ILayerZeroEndpointV2.sol';

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
  ) external payable;

  /**
   * @notice Retrieves the next nonce for a given source endpoint and sender address.
   * @dev _srcEid The source endpoint ID.
   * @dev _sender The sender address.
   * @return nonce The next nonce.
   *
   * @dev The path nonce starts from 1. If 0 is returned it means that there is NO nonce ordered enforcement.
   * @dev Is required by the off-chain executor to determine the OApp expects msg execution is ordered.
   * @dev This is also enforced by the OApp.
   * @dev By default this is NOT enabled. ie. nextNonce is hardcoded to return 0.
   */
  function nextNonce(uint32 /*_srcEid*/, bytes32 /*_sender*/) external view returns (uint64 nonce);
}
