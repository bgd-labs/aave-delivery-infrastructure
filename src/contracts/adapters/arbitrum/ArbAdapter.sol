// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {IArbAdapter} from './IArbAdapter.sol';
import {IInbox} from './interfaces/IInbox.sol';
import {AddressAliasHelper} from './libs/AddressAliasHelper.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';

/**
 * @title ArbAdapter
 * @author BGD Labs
 * @notice Arbitrum bridge adapter. Used to send and receive messages cross chain between Ethereum and Arbitrum
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 * @dev note that this adapter can only be used for the communication path ETHEREUM -> ARBITRUM
 */
contract ArbAdapter is IArbAdapter, BaseAdapter {
  /// @inheritdoc IArbAdapter
  address public immutable INBOX;

  /// @inheritdoc IArbAdapter
  address public immutable DESTINATION_CCC;

  /// @inheritdoc IArbAdapter
  uint256 public constant BASE_FEE_MARGIN = 10 gwei;

  /// @inheritdoc IArbAdapter
  uint256 public constant L2_MAX_FEE_PER_GAS = 1 gwei;

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param inbox arbitrum entry point address
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address inbox,
    address destinationCCC,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Arbitrum native adapter', trustedRemotes) {
    INBOX = inbox;
    DESTINATION_CCC = destinationCCC;
  }

  /// @inheritdoc IArbAdapter
  function getRequiredGas(
    uint256 bytesLength,
    uint256 gasLimit
  ) public view returns (uint256, uint256) {
    return (
      IInbox(INBOX).calculateRetryableSubmissionFee(bytesLength, block.basefee + BASE_FEE_MARGIN),
      gasLimit * L2_MAX_FEE_PER_GAS
    );
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    bytes memory data = abi.encodeWithSelector(IArbAdapter.arbReceive.selector, message);

    uint256 totalGasLimit = executionGasLimit + BASE_GAS_LIMIT;

    (uint256 maxSubmission, uint256 maxRedemption) = getRequiredGas(data.length, totalGasLimit);
    uint256 ticketID = _forwardMessage(
      MessageInformation({
        receiver: receiver,
        executionGasLimit: totalGasLimit,
        encodedMessage: data,
        maxSubmission: maxSubmission,
        maxRedemption: maxRedemption
      })
    );

    return (INBOX, ticketID);
  }

  /// @inheritdoc IArbAdapter
  function arbReceive(bytes calldata message) external {
    uint256 originChainId = getOriginChainId();
    address srcAddress = AddressAliasHelper.undoL1ToL2Alias(msg.sender);
    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originChainId);
  }

  /// @inheritdoc IArbAdapter
  function getOriginChainId() public view virtual returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  /// @inheritdoc IArbAdapter
  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool) {
    return chainId == ChainIds.ARBITRUM;
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }

  /**
   * @notice method that forwards a message to a destination
   * @param message object with the necessary information to pay and send a message to a destination
   * @return identifier of the sent transaction
   */
  function _forwardMessage(MessageInformation memory message) internal returns (uint256) {
    uint256 requiredGas = message.maxSubmission + message.maxRedemption;
    require(address(this).balance >= requiredGas, Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES);

    return
      IInbox(INBOX).createRetryableTicket{value: requiredGas}(
        message.receiver,
        0,
        message.maxSubmission,
        DESTINATION_CCC,
        DESTINATION_CCC,
        message.executionGasLimit,
        L2_MAX_FEE_PER_GAS,
        message.encodedMessage
      );
  }
}
