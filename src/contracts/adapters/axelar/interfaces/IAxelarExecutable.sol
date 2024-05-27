// SPDX-License-Identifier: MIT
// Modified from commit https://github.com/axelarnetwork/axelar-gmp-sdk-solidity/commit/f0222fe45be6c463914924850b5521826dec1b75
pragma solidity ^0.8.0;

interface IAxelarExecutable {
  function execute(
    bytes32 commandId,
    string calldata sourceChain,
    string calldata sourceAddress,
    bytes calldata payload
  ) external;
}
