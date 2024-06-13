// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAxelarGateway} from './interfaces/IAxelarGateway.sol';
import {IAxelarGasService} from './interfaces/IAxelarGasService.sol';
import {IBaseAdapter} from '../BaseAdapter.sol';

/**
 * @title IAxelarAdapter
 * @author BGD Labs
 * @notice interface containing the events, objects and method definitions used in the Axelar bridge adapter
 */
interface IAxelarAdapter {
  /**
   * @notice Adapter constructor arguments
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   * @param gateway address of the axelar gateway endpoint on the current chain where adapter is deployed
   * @param gasService address of the axelar gas service endpoint on the current chain where adapter is deployed
   */
  struct AxelarAdapterArgs {
    address crossChainController;
    uint256 providerGasLimit;
    IBaseAdapter.TrustedRemotesConfig[] trustedRemotes;
    address gateway;
    address gasService;
  }

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

  /**
   * @notice method to get infrastructure chain id from bridge native chain id
   * @param nativeChainId bridge native chain id
   */
  function axelarNativeToInfraChainId(string memory nativeChainId) external returns (uint256);

  /**
   * @notice method to get bridge native chain id from native bridge chain id
   * @param infraChainId infrastructure chain id
   */
  function axelarInfraToNativeChainId(uint256 infraChainId) external returns (string memory);
}
