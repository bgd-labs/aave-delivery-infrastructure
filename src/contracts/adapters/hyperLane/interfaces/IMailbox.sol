// SPDX-License-Identifier: MIT OR Apache-2.0
// Modified from commit: https://github.com/hyperlane-xyz/hyperlane-monorepo/commit/62211b92e3c8336b0c6a1ea65ec248524106a707
pragma solidity >=0.8.0;

import {IPostDispatchHook} from './IPostDispatchHook.sol';

interface IMailbox {
  function dispatch(
    uint32 destinationDomain,
    bytes32 recipientAddress,
    bytes calldata messageBody
  ) external payable returns (bytes32 messageId);

  //  function quoteDispatch(
  //    uint32 destinationDomain,
  //    bytes32 recipientAddress,
  //    bytes calldata messageBody
  //  ) external view returns (uint256 fee);

  //  function dispatch(
  //    uint32 destinationDomain,
  //    bytes32 recipientAddress,
  //    bytes calldata body,
  //    bytes calldata defaultHookMetadata
  //  ) external payable returns (bytes32 messageId);

  function quoteDispatch(
    uint32 destinationDomain,
    bytes32 recipientAddress,
    bytes calldata messageBody,
    bytes calldata defaultHookMetadata
  ) external view returns (uint256 fee);

  //  function dispatch(
  //    uint32 destinationDomain,
  //    bytes32 recipientAddress,
  //    bytes calldata body,
  //    bytes calldata customHookMetadata,
  //    IPostDispatchHook customHook
  //  ) external payable returns (bytes32 messageId);

  //  function quoteDispatch(
  //    uint32 destinationDomain,
  //    bytes32 recipientAddress,
  //    bytes calldata messageBody,
  //    bytes calldata customHookMetadata,
  //    IPostDispatchHook customHook
  //  ) external view returns (uint256 fee);
}
