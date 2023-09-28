// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

contract MockDelegateCallProxy {
  address immutable owner;

  constructor() {
    owner = msg.sender;
  }

  function execute(address target, bytes calldata data) external payable {
    require(msg.sender == owner, 'only owner');
    (bool success, ) = target.delegatecall(data);
    require(success, 'DelegateCallProxy: delegatecall failed');
  }

  receive() external payable {}
}
