// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMailbox} from 'hyperlane-monorepo/interfaces/IMailbox.sol';
import {IInterchainGasPaymaster} from 'hyperlane-monorepo/interfaces/IInterchainGasPaymaster.sol';

/**
 * @title IHyperLaneAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the HyperLane bridge adapter
 */
interface IHyperLaneAdapter {
  /**
   * @notice method to get the current Mail Box address
   * @return the address of the HyperLane Mail Box
   */
  function HL_MAIL_BOX() external view returns (IMailbox);

  /**
   * @notice method to get the current IGP address
   * @return the address of the HyperLane IGP
   */
  function IGP() external view returns (IInterchainGasPaymaster);
}
