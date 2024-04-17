// SPDX-License-Identifier: MIT OR Apache-2.0
// Copied from commit: https://github.com/hyperlane-xyz/hyperlane-monorepo/commit/7309f770ef948211a7bb637e56835f436d14eec7
pragma solidity >=0.6.11;

interface IMessageRecipient {
  function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable;
}
