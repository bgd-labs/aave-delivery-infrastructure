// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IBaseReceiverPortal} from '../../src/contracts/interfaces/IBaseReceiverPortal.sol';

contract FailingReceiver is IBaseReceiverPortal {
  function receiveCrossChainMessage(address, uint256, bytes memory) external pure {
    revert('error message');
  }
}
