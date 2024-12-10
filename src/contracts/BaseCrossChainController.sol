// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {Initializable} from 'solidity-utils/contracts/transparent-proxy/Initializable.sol';
import {Rescuable, RescuableBase, IERC20} from 'solidity-utils/contracts/utils/Rescuable.sol';
import {IRescuable, IRescuableBase} from 'solidity-utils/contracts/utils/interfaces/IRescuable.sol';
import {CrossChainReceiver} from './CrossChainReceiver.sol';
import {CrossChainForwarder} from './CrossChainForwarder.sol';
import {Errors} from './libs/Errors.sol';

import {IBaseCrossChainController} from './interfaces/IBaseCrossChainController.sol';

/**
 * @title BaseCrossChainController
 * @author BGD Labs
 * @notice Contract with the logic to manage sending and receiving messages cross chain.
 * @dev This contract is enabled to receive gas tokens as its the one responsible for bridge services payment.
        It should always be topped up, or no messages will be sent to other chains
 */
contract BaseCrossChainController is
  IBaseCrossChainController,
  Rescuable,
  CrossChainForwarder,
  CrossChainReceiver,
  Initializable
{
  constructor()
    CrossChainReceiver(new ConfirmationInput[](0), new ReceiverBridgeAdapterConfigInput[](0))
    CrossChainForwarder(
      new ForwarderBridgeAdapterConfigInput[](0),
      new address[](0),
      new OptimalBandwidthByChain[](0)
    )
  {}

  /// @dev child class should make a call of this method
  function _baseInitialize(
    address owner,
    address guardian,
    ConfirmationInput[] memory initialRequiredConfirmations,
    ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove,
    OptimalBandwidthByChain[] memory optimalBandwidthByChain
  ) internal initializer {
    _transferOwnership(owner);
    _updateGuardian(guardian);

    _configureReceiverBasics(
      receiverBridgeAdaptersToAllow,
      new ReceiverBridgeAdapterConfigInput[](0), // On first init, no bridges to disable
      initialRequiredConfirmations
    );

    _configureForwarderBasics(
      forwarderBridgeAdaptersToEnable,
      new BridgeAdapterToDisable[](0), // On first init, no bridges to disable
      sendersToApprove,
      new address[](0), // On first init, no senders to unauthorize
      optimalBandwidthByChain
    );
  }

  /// @inheritdoc Rescuable
  function whoCanRescue() public view override(Rescuable) returns (address) {
    return owner();
  }

  /// @inheritdoc IRescuableBase
  function maxRescue(
    address erc20Token
  ) public view override(IRescuableBase, RescuableBase) returns (uint256) {
    return IERC20(erc20Token).balanceOf(address(this));
  }

  /// @notice Enable contract to receive ETH/Native token
  receive() external payable {}
}
