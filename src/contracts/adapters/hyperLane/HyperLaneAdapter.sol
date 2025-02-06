// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {IMessageRecipient} from './interfaces/IMessageRecipient.sol';
import {TypeCasts} from './libs/TypeCasts.sol';
import {StandardHookMetadata} from './libs/StandardHookMetadata.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {IHyperLaneAdapter, IMailbox} from './IHyperLaneAdapter.sol';
import {Errors} from '../../libs/Errors.sol';

/**
 * @title HyperLaneAdapter
 * @author BGD Labs
 * @notice HyperLane bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract HyperLaneAdapter is BaseAdapter, IHyperLaneAdapter, IMessageRecipient {
  /// @inheritdoc IHyperLaneAdapter
  IMailbox public immutable HL_MAIL_BOX;

  /// @notice modifier to check that caller is hyper lane mailBox
  modifier onlyMailbox() {
    require(msg.sender == address(HL_MAIL_BOX), Errors.CALLER_NOT_HL_MAILBOX);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param mailBox HyperLane router contract address to send / receive cross chain messages
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address mailBox,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Hyperlane adapter', trustedRemotes) {
    require(mailBox != address(0), Errors.INVALID_HL_MAILBOX);
    HL_MAIL_BOX = IMailbox(mailBox);
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    uint32 nativeChainId = SafeCast.toUint32(infraToNativeChainId(destinationChainId));
    require(nativeChainId != uint32(0), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    bytes memory metadata = StandardHookMetadata.overrideGasLimit(
      executionGasLimit + BASE_GAS_LIMIT
    );

    // Get the required payment from the MAILBOX.
    uint256 quotedPayment = HL_MAIL_BOX.quoteDispatch(
      nativeChainId,
      TypeCasts.addressToBytes32(receiver),
      message,
      metadata
    );

    require(quotedPayment <= address(this).balance, Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES);

    bytes32 messageId = HL_MAIL_BOX.dispatch{value: quotedPayment}(
      nativeChainId,
      TypeCasts.addressToBytes32(receiver),
      message,
      metadata
    );

    return (address(HL_MAIL_BOX), uint256(messageId));
  }

  /// @inheritdoc IMessageRecipient
  function handle(
    uint32 _origin,
    bytes32 _sender,
    bytes calldata _messageBody
  ) external payable onlyMailbox {
    address srcAddress = TypeCasts.bytes32ToAddress(_sender);

    uint256 originChainId = nativeToInfraChainId(_origin);

    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );
    _registerReceivedMessage(_messageBody, originChainId);
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }
}
