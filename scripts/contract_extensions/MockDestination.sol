// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IBaseReceiverPortal} from '../../src/contracts/interfaces/IBaseReceiverPortal.sol';

contract MockDestination is IBaseReceiverPortal {
  address public immutable CROSS_CHAIN_CONTROLLER;

  event TestWorked(address indexed originSender, uint256 indexed originChainId, bytes message);

  constructor(address crossChainController) {
    require(crossChainController != address(0), 'WRONG_CROSS_CHAIN_CONTROLLER');
    CROSS_CHAIN_CONTROLLER = crossChainController;
  }

  function receiveCrossChainMessage(
    address originSender,
    uint256 originChainId,
    bytes memory message
  ) external {
    require(msg.sender == CROSS_CHAIN_CONTROLLER, 'CALLER_NOT_CROSS_CHAIN_CONTROLLER');
    emit TestWorked(originSender, originChainId, message);
  }
}
