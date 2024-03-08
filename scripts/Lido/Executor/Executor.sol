// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IBaseReceiverPortal} from "../../../src/contracts/interfaces/IBaseReceiverPortal.sol";

import {BridgeExecutorBase} from './BridgeExecutorBase.sol';

/**
 * @title PolygonBridgeExecutor
 * @author Aave
 * @notice Implementation of the Polygon Bridge Executor, able to receive cross-chain transactions from Ethereum
 * @dev Queuing an ActionsSet into this Executor can only be done by the FxChild and after passing the EthereumGovernanceExecutor check
 * as the FxRoot sender
 */
contract Executor is BridgeExecutorBase, IBaseReceiverPortal {

  /**
   * @dev Address of the CrossChainController contract on the current chain.
   */
  address public immutable CROSS_CHAIN_CONTROLLER;

  /**
   * @dev Address of the DAO Agent contract on the root chain.
   */
  address public immutable DAO_AGENT;

  /**
   * @dev Root Chain ID of the DAO Agent contract.
   */
  uint256 public immutable DAO_AGENT_CHAIN_ID;

  error InvalidCrossChainController();
  error InvalidDaoAgentAddress();
  error InvalidDaoAgentChainId();
  error InvalidCaller();
  error InvalidSenderAddress();
  error InvalidSenderChainId();

  event MessageReceived(address indexed originSender, uint256 indexed originChainId, bytes message);

  /**
   * @dev Only allows the CrossChainController to call the function
   */
  modifier onlyCrossChainController() {
    if (msg.sender != CROSS_CHAIN_CONTROLLER) revert InvalidCaller();
    _;
  }

  /**
   * @dev Constructor
   *
   * @param _crossChainController - Address of the CrossChainController contract on the current chain
   * @param _daoAgent - Address of the DAO Aragon Agent contract on the root chain
   * @param _daoAgentChainId - Chain ID of the DAO Aragon Agent contract
   * @param _delay - The delay before which an actions set can be executed
   * @param _gracePeriod - The time period after a delay during which an actions set can be executed
   * @param _minimumDelay - The minimum bound a delay can be set to
   * @param _maximumDelay - The maximum bound a delay can be set to
   * @param _guardian - The address of the guardian, which can cancel queued proposals (can be zero)
   */
  constructor(
    address _crossChainController,
    address _daoAgent,
    uint256 _daoAgentChainId,
    uint256 _delay,
    uint256 _gracePeriod,
    uint256 _minimumDelay,
    uint256 _maximumDelay,
    address _guardian
  ) BridgeExecutorBase(_delay, _gracePeriod, _minimumDelay, _maximumDelay, _guardian) {
    if (_crossChainController == address(0)) revert InvalidCrossChainController();
    if (_daoAgent == address(0)) revert InvalidDaoAgentAddress();
    if (_daoAgentChainId == 0) revert InvalidDaoAgentChainId();

    CROSS_CHAIN_CONTROLLER = _crossChainController;
    DAO_AGENT = _daoAgent;
    DAO_AGENT_CHAIN_ID = _daoAgentChainId;
  }

  /**
   * @notice method called by CrossChainController when a message has been confirmed
   * @param originSender address of the sender of the bridged message
   * @param originChainId id of the chain where the message originated
   * @param message bytes bridged containing the desired information
   */
  function receiveCrossChainMessage(
    address originSender,
    uint256 originChainId,
    bytes memory message
  ) external override onlyCrossChainController {
    if (originSender != DAO_AGENT) revert InvalidSenderAddress();
    if (originChainId != DAO_AGENT_CHAIN_ID) revert InvalidSenderChainId();

    // _receiveCrossChainMessage(message);

    emit MessageReceived(originSender, originChainId, message);
  }

  function _receiveCrossChainMessage(bytes memory data) internal {
    address[] memory targets;
    uint256[] memory values;
    string[] memory signatures;
    bytes[] memory calldatas;
    bool[] memory withDelegatecalls;

    (targets, values, signatures, calldatas, withDelegatecalls) = abi.decode(
      data,
      (address[], uint256[], string[], bytes[], bool[])
    );

    _queue(targets, values, signatures, calldatas, withDelegatecalls);
  }
}
