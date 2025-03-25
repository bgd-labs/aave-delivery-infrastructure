// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {OpAdapter, IOpAdapter} from '../optimism/OpAdapter.sol';

/**
 * @param crossChainController address of the cross chain controller that will use this bridge adapter
 * @param ovmCrossDomainMessenger ink entry point address
 * @param providerGasLimit base gas limit used by the bridge adapter
 * @param trustedRemotes list of remote configurations to set as trusted
 */
struct InkAdapterArgs {
  address crossChainController;
  address ovmCrossDomainMessenger;
  uint256 providerGasLimit;
  IBaseAdapter.TrustedRemotesConfig[] trustedRemotes;
}

/**
 * @title InkAdapter
 * @author BGD Labs
 * @notice Ink bridge adapter. Used to send and receive messages cross chain between Ethereum and Ink
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 * @dev note that this adapter can only be used for the communication path ETHEREUM -> INK
 * @dev note that this adapter inherits from Optimism adapter and overrides only supported chain
 */
contract InkAdapter is OpAdapter {
  /**
   * @param args InkAdapterArgs necessary to initialize the adapter
   */
  constructor(
    InkAdapterArgs memory args
  )
    OpAdapter(
      args.crossChainController,
      args.ovmCrossDomainMessenger,
      args.providerGasLimit,
      'Ink native adapter',
      args.trustedRemotes
    )
  {}

  /// @inheritdoc IOpAdapter
  function isDestinationChainIdSupported(
    uint256 chainId
  ) public view virtual override returns (bool) {
    return chainId == ChainIds.INK;
  }

  /// @inheritdoc IOpAdapter
  function getOriginChainId() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}
