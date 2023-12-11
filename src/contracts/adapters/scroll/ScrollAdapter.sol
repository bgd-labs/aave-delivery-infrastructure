// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from '../../libs/ChainIds.sol';
import {OpAdapter, IOpAdapter, IBaseAdapter} from '../optimism/OpAdapter.sol';

/**
 * @title ScrollAdapter
 * @author BGD Labs
 * @notice Scroll bridge adapter. Used to send and receive messages cross chain between Ethereum and Scroll
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 * @dev note that this adapter can only be used for the communication path ETHEREUM -> SCROLL
 * @dev note that this adapter inherits from Optimism adapter and overrides supported chain and forwardMessage
 */
contract ScrollAdapter is OpAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param ovmCrossDomainMessenger optimism entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address ovmCrossDomainMessenger,
    TrustedRemotesConfig[] memory trustedRemotes
  ) OpAdapter(crossChainController, ovmCrossDomainMessenger, trustedRemotes) {}

  /// @inheritdoc IOpAdapter
  function isDestinationChainIdSupported(
    uint256 chainId
  ) public view virtual override returns (bool) {
    return chainId == ChainIds.SCROLL;
  }

  /// @inheritdoc IOpAdapter
  function getOriginChainId() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}
