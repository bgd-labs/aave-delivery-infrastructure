// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAxelarGateway} from './interfaces/IAxelarGateway.sol';
import {IAxelarGasService} from './interfaces/IAxelarGasService.sol';

/**
 * @title IAxelarAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the Axelar bridge adapter
 */
interface IAxelarAdapter {
  /**
   * @notice returns the Axelar gateway endpoint address
   * @return Axelar gateway endpoint address
   */
  function AXELAR_GATEWAY() external view returns (IAxelarGateway);

  /**
   * @notice returns the Axelar gas service endpoint address
   * @return Axelar gas service endpoint address
   */
  function AXELAR_GAS_SERVICE() external view returns (IAxelarGasService);
}
