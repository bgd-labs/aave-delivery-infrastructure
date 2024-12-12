// SPDX-License-Identifier: MIT
// Modified from: https://docs.linea.build/get-started/concepts/message-service#interface-imessageservicesol
pragma solidity ^0.8.0;

interface IMessageService {
  /**
   * @notice Sends a message for transporting from the given chain.
   * @dev This function should be called with a msg.value = _value + _fee. The fee will be paid on the destination chain.
   * @param _to The destination address on the destination chain.
   * @param _fee The message service fee on the origin chain.
   * @param _calldata The calldata used by the destination message service to call the destination contract.
   */
  function sendMessage(address _to, uint256 _fee, bytes calldata _calldata) external payable;

  /**
   * @notice Returns the original sender of the message on the origin layer.
   * @return The original sender of the message on the origin layer.
   */
  function sender() external view returns (address);
}
