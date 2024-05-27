// SPDX-License-Identifier: MIT
// Modified from commit: https://github.com/axelarnetwork/axelar-cgp-solidity/commit/f6c45b1c8b6c70199925a5c0e35205b544db0a41
pragma solidity ^0.8.0;

interface IAxelarGateway {
  function callContract(
    string calldata destinationChain,
    string calldata contractAddress,
    bytes calldata payload
  ) external;

  /**********************\
  |* External Functions *|
  \**********************/

  function execute(bytes calldata input) external;
}
