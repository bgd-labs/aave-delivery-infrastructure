// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAxelarAdapter, IAxelarGateway, IAxelarGasService} from './IAxelarAdapter.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {Errors} from '../../libs/Errors.sol';

/**
 * @title AxekarAdapter
 * @author BGD Labs
 * @notice Axelar bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract AxelarAdapter is BaseAdapter, IAxelarAdapter {
  IAxelarGateway public immutable AXELAR_GATEWAY;

  IAxelarGasService public immutable AXELAR_GAS_SERVICE;

  /**
   * @notice constructor for the Axelar adapter
   * @param gateway address of the axelar gateway endpoint on the current chain where adapter is deployed
   * @param gasService address of the axelar gas service endpoint on the current chain where adapter is deployed
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address gateway,
    address gasService,
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Axelar adapter', trustedRemotes) {
    require(gateway != address(0), Errors.INVALID_AXELAR_GATEWAY);
    require(gasService != address(0), Errors.INVALID_AXELAR_GAS_SERVICE);
    AXELAR_GATEWAY = IAxelarGateway(gateway);
    AXELAR_GAS_SERVICE = IAxelarGasService(gasService);
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {}
}
