// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from '../../libs/ChainIds.sol';
import {OpAdapter, IOpAdapter, IBaseAdapter, Errors} from '../optimism/OpAdapter.sol';
import {IScrollMessenger, IL1MessageQueue} from './interfaces/IScrollMessenger.sol';

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
  // based on the recommendation of the Scroll team made immutable, because it can't change.
  // Even if it's a variable on the Messenger side, will become immutable as well in the next update
  IL1MessageQueue public immutable SCROLL_MESSAGE_QUEUE;

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param ovmCrossDomainMessenger optimism entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address ovmCrossDomainMessenger,
    TrustedRemotesConfig[] memory trustedRemotes
  ) OpAdapter(crossChainController, ovmCrossDomainMessenger, trustedRemotes) {
    SCROLL_MESSAGE_QUEUE = IScrollMessenger(OVM_CROSS_DOMAIN_MESSENGER).messageQueue();
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 destinationGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external virtual override returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    // L2 message delivery fee
    uint256 fee = SCROLL_MESSAGE_QUEUE.estimateCrossDomainMessageFee(destinationGasLimit);

    IScrollMessenger(OVM_CROSS_DOMAIN_MESSENGER).sendMessage{value: fee}(
      receiver,
      fee,
      abi.encodeWithSelector(IOpAdapter.ovmReceive.selector, message),
      destinationGasLimit
    );

    return (OVM_CROSS_DOMAIN_MESSENGER, 0);
  }

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
