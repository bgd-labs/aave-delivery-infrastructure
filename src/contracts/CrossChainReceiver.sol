// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

import {ICrossChainReceiver, EnumerableSet} from './interfaces/ICrossChainReceiver.sol';
import {IBaseReceiverPortal} from './interfaces/IBaseReceiverPortal.sol';
import {Transaction, Envelope, TransactionUtils} from './libs/EncodingUtils.sol';
import {Errors} from './libs/Errors.sol';

/**
 * @title CrossChainReceiver
 * @author BGD Labs
 * @notice this contract contains the methods to get bridged messages and route them to their respective recipients.
 * @dev to route a message, this one needs to be bridged correctly n number of confirmations.
 * @dev if at some point, it is detected that some bridge has been hacked, there is a possibility to invalidate
 *      messages by calling updateMessagesValidityTimestamp
 */
contract CrossChainReceiver is OwnableWithGuardian, ICrossChainReceiver {
  using EnumerableSet for EnumerableSet.AddressSet;
  using EnumerableSet for EnumerableSet.UintSet;

  // chainId => configuration
  mapping(uint256 => ReceiverConfigurationFull) internal _configurationsByChain;

  // stores hash(Transaction) => bridged transaction information and state
  mapping(bytes32 => TransactionState) internal _transactionsState;

  // stores hash(Envelope) => received envelope state
  mapping(bytes32 => EnvelopeState) internal _envelopesState;

  // stores the currently supported chains (chains that have at least 1 bridge adapter)
  EnumerableSet.UintSet internal _supportedChains;

  // storage gap allocation to be used for later updates. This way storage can be added on parent contract without
  // overwriting storage on child
  uint256[50] private __RECEIVER_GAP;

  // checks if caller is one of the approved bridge adapters
  modifier onlyApprovedBridges(uint256 chainId) {
    require(isReceiverBridgeAdapterAllowed(msg.sender, chainId), Errors.CALLER_NOT_APPROVED_BRIDGE);
    _;
  }

  /**
   * @param initialRequiredConfirmations number of confirmations the messages need to be accepted as valid
   * @param bridgeAdaptersToAllow array of objects containing the chain and address of the bridge adapters that
            can receive messages
   */
  constructor(
    ConfirmationInput[] memory initialRequiredConfirmations,
    ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersToAllow
  ) {
    _configureReceiverBasics(
      bridgeAdaptersToAllow,
      new ReceiverBridgeAdapterConfigInput[](0),
      initialRequiredConfirmations
    );
  }

  /// @inheritdoc ICrossChainReceiver
  function getReceiverBridgeAdaptersByChain(
    uint256 chainId
  ) public view returns (address[] memory) {
    return _configurationsByChain[chainId].allowedBridgeAdapters.values();
  }

  /// @inheritdoc ICrossChainReceiver
  function getSupportedChains() external view returns (uint256[] memory) {
    return _supportedChains.values();
  }

  /// @inheritdoc ICrossChainReceiver
  function getConfigurationByChain(
    uint256 chainId
  ) external view returns (ReceiverConfiguration memory) {
    return _configurationsByChain[chainId].configuration;
  }

  /// @inheritdoc ICrossChainReceiver
  function isReceiverBridgeAdapterAllowed(
    address bridgeAdapter,
    uint256 chainId
  ) public view returns (bool) {
    return _configurationsByChain[chainId].allowedBridgeAdapters.contains(bridgeAdapter);
  }

  /// @inheritdoc ICrossChainReceiver
  function getTransactionState(
    bytes32 transactionId
  ) public view returns (TransactionStateWithoutAdapters memory) {
    return
      TransactionStateWithoutAdapters({
        confirmations: _transactionsState[transactionId].confirmations,
        firstBridgedAt: _transactionsState[transactionId].firstBridgedAt
      });
  }

  /// @inheritdoc ICrossChainReceiver
  function getTransactionState(
    Transaction memory transaction
  ) external view returns (TransactionStateWithoutAdapters memory) {
    return getTransactionState(transaction.getId());
  }

  /// @inheritdoc ICrossChainReceiver
  function getEnvelopeState(Envelope memory envelope) external view returns (EnvelopeState) {
    return getEnvelopeState(envelope.getId());
  }

  /// @inheritdoc ICrossChainReceiver
  function getEnvelopeState(bytes32 envelopeId) public view returns (EnvelopeState) {
    return _envelopesState[envelopeId];
  }

  /// @inheritdoc ICrossChainReceiver
  function isTransactionReceivedByAdapter(
    bytes32 transactionId,
    address bridgeAdapter
  ) external view returns (bool) {
    return _transactionsState[transactionId].bridgedByAdapter[bridgeAdapter];
  }

  /// @inheritdoc ICrossChainReceiver
  function updateConfirmations(ConfirmationInput[] memory newConfirmations) external onlyOwner {
    _updateConfirmations(newConfirmations);
  }

  /// @inheritdoc ICrossChainReceiver
  function updateMessagesValidityTimestamp(
    ValidityTimestampInput[] memory newValidityTimestamp
  ) external onlyOwner {
    _updateMessagesValidityTimestamp(newValidityTimestamp);
  }

  /// @inheritdoc ICrossChainReceiver
  function allowReceiverBridgeAdapters(
    ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput
  ) external onlyOwner {
    _updateReceiverBridgeAdapters(bridgeAdaptersInput, true);
  }

  /// @inheritdoc ICrossChainReceiver
  function disallowReceiverBridgeAdapters(
    ReceiverBridgeAdapterConfigInput[] memory bridgeAdapters
  ) external onlyOwner {
    _updateReceiverBridgeAdapters(bridgeAdapters, false);
  }

  /// @inheritdoc ICrossChainReceiver
  function receiveCrossChainMessage(
    bytes memory encodedTransaction,
    uint256 originChainId
  ) external onlyApprovedBridges(originChainId) {
    Transaction memory transaction = TransactionUtils.decode(encodedTransaction);
    Envelope memory envelope = transaction.getEnvelope();
    require(
      envelope.originChainId == originChainId && envelope.destinationChainId == block.chainid,
      Errors.CHAIN_ID_MISMATCH
    );
    bytes32 envelopeId = transaction.getEnvelopeId();

    bytes32 transactionId = TransactionUtils.getId(encodedTransaction);

    TransactionState storage internalTransaction = _transactionsState[transactionId];
    ReceiverConfiguration memory configuration = _configurationsByChain[originChainId]
      .configuration;

    // If bridged at is > invalidation, it means that the first time transaction was received after last invalidation and
    // can be processed.
    // 0 here means that it’s received for a first time, so invalidation does not matter for this message.
    // Also checks that bridge adapter didn’t bridge this transaction already.
    // Dont let messages pass if required confirmations are 0. Meaning that they have not been configured
    uint120 transactionFirstBridgedAt = internalTransaction.firstBridgedAt;
    if (
      transactionFirstBridgedAt == 0 ||
      (!internalTransaction.bridgedByAdapter[msg.sender] &&
        transactionFirstBridgedAt > configuration.validityTimestamp)
    ) {
      if (transactionFirstBridgedAt == 0) {
        internalTransaction.firstBridgedAt = uint120(block.timestamp);
      }

      uint8 newConfirmations = ++internalTransaction.confirmations;
      internalTransaction.bridgedByAdapter[msg.sender] = true;

      emit TransactionReceived(
        transactionId,
        envelopeId,
        originChainId,
        transaction,
        msg.sender,
        newConfirmations
      );
      // Checks that the message was not confirmed and/or delivered before, so it will not try to deliver again when message arrives
      // from additional bridges after reaching required number of confirmations
      if (_envelopesState[envelopeId] != EnvelopeState.None) {
        return;
      }

      // >= is used for the case when confirmations gets lowered before message reached the old _requiredConfirmations
      // but on receiving new messages it surpasses the current _requiredConfirmations. So it doesn't get stuck (if using ==)
      if (
        configuration.requiredConfirmation > 0 &&
        newConfirmations >= configuration.requiredConfirmation
      ) {
        _envelopesState[envelopeId] = EnvelopeState.Delivered;
        try
          IBaseReceiverPortal(envelope.destination).receiveCrossChainMessage(
            envelope.origin,
            envelope.originChainId,
            envelope.message
          )
        {
          emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
        } catch (bytes memory) {
          _envelopesState[envelopeId] = EnvelopeState.Confirmed;
          emit EnvelopeDeliveryAttempted(envelopeId, envelope, false);
        }
      }
    }
  }

  /// @inheritdoc ICrossChainReceiver
  function deliverEnvelope(Envelope memory envelope) external {
    bytes32 envelopeId = envelope.getId();
    require(
      _envelopesState[envelopeId] == EnvelopeState.Confirmed,
      Errors.ENVELOPE_NOT_CONFIRMED_OR_DELIVERED
    );

    _envelopesState[envelopeId] = EnvelopeState.Delivered;
    IBaseReceiverPortal(envelope.destination).receiveCrossChainMessage(
      envelope.origin,
      envelope.originChainId,
      envelope.message
    );
    emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
  }

  /**
   * @notice method to set a new timestamp from where the messages will be valid.
   * @param newValidityTimestampsInput array of objects containing the chain and timestamp where all the previous unconfirmed
            messages must be invalidated.
   */
  function _updateMessagesValidityTimestamp(
    ValidityTimestampInput[] memory newValidityTimestampsInput
  ) internal {
    for (uint256 i; i < newValidityTimestampsInput.length; i++) {
      ValidityTimestampInput memory input = newValidityTimestampsInput[i];
      require(
        input.validityTimestamp >
          _configurationsByChain[input.chainId].configuration.validityTimestamp &&
          input.validityTimestamp <= block.timestamp,
        Errors.INVALID_VALIDITY_TIMESTAMP
      );
      _configurationsByChain[input.chainId].configuration.validityTimestamp = input
        .validityTimestamp;

      emit NewInvalidation(input.validityTimestamp, input.chainId);
    }
  }

  /**
   * @notice method to update the number of confirmations necessary for the messages to be accepted as valid
   * @param newConfirmations array of objects with the chainId and the new number of needed confirmations
   */
  function _updateConfirmations(ConfirmationInput[] memory newConfirmations) internal {
    for (uint256 i; i < newConfirmations.length; i++) {
      ConfirmationInput memory confirmations = newConfirmations[i];
      require(
        confirmations.requiredConfirmations > 0 &&
          confirmations.requiredConfirmations <=
          _configurationsByChain[confirmations.chainId].allowedBridgeAdapters.length(),
        Errors.INVALID_REQUIRED_CONFIRMATIONS
      );
      _configurationsByChain[confirmations.chainId]
        .configuration
        .requiredConfirmation = confirmations.requiredConfirmations;
      emit ConfirmationsUpdated(confirmations.requiredConfirmations, confirmations.chainId);
    }
  }

  /**
   * @notice method to add bridge adapters to the allowed list
   * @param bridgeAdaptersInput array of objects with the new bridge adapters and supported chains
   */
  function _updateReceiverBridgeAdapters(
    ReceiverBridgeAdapterConfigInput[] memory bridgeAdaptersInput,
    bool isAllowed
  ) internal {
    for (uint256 i = 0; i < bridgeAdaptersInput.length; i++) {
      ReceiverBridgeAdapterConfigInput memory input = bridgeAdaptersInput[i];
      require(input.bridgeAdapter != address(0), Errors.INVALID_BRIDGE_ADAPTER);

      for (uint256 j; j < input.chainIds.length; j++) {
        bool actionProcessed;
        if (isAllowed) {
          _supportedChains.add(input.chainIds[j]);
          actionProcessed = _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.add(
            input.bridgeAdapter
          );
        } else {
          actionProcessed = _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.remove(
            input.bridgeAdapter
          );
          if (
            actionProcessed &&
            _configurationsByChain[input.chainIds[j]].allowedBridgeAdapters.length() == 0
          ) {
            _supportedChains.remove(input.chainIds[j]);
          }
        }
        if (actionProcessed) {
          emit ReceiverBridgeAdaptersUpdated(input.bridgeAdapter, isAllowed, input.chainIds[j]);
        }
      }
    }
  }

  /// @dev utility function, defining an order of actions commonly done in batch
  function _configureReceiverBasics(
    ReceiverBridgeAdapterConfigInput[] memory bridgesToEnable,
    ReceiverBridgeAdapterConfigInput[] memory bridgesToDisable,
    ConfirmationInput[] memory newConfirmations
  ) internal {
    // IMPORTANT. Confirmations update should always happen after adapters, to not create a situation of
    // blockage in the system
    _updateReceiverBridgeAdapters(bridgesToEnable, true);
    _updateReceiverBridgeAdapters(bridgesToDisable, false);
    _updateConfirmations(newConfirmations);
  }
}
