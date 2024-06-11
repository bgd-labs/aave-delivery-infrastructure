// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAxelarAdapter, IAxelarGateway, IAxelarGasService} from './IAxelarAdapter.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {Errors} from '../../libs/Errors.sol';
import {IAxelarExecutable} from './interfaces/IAxelarExecutable.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';
import {StringToAddress} from './libs/StringToAddress.sol';

/**
 * @title AxelarAdapter
 * @author BGD Labs
 * @notice Axelar bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract AxelarAdapter is BaseAdapter, IAxelarAdapter, IAxelarExecutable {
  using Strings for string;

  /// @inheritdoc IAxelarAdapter
  IAxelarGateway public immutable AXELAR_GATEWAY;

  /// @inheritdoc IAxelarAdapter
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
  ) external returns (address, uint256) {
    string memory nativeChainId = axelarInfraToNativeChainId(destinationChainId);
    require(!nativeChainId.equal(''), Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED);
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    uint256 totalGasLimit = executionGasLimit + BASE_GAS_LIMIT;

    uint256 gasEstimate = AXELAR_GAS_SERVICE.estimateGasFee(
      nativeChainId,
      Strings.toHexString(receiver),
      message,
      totalGasLimit,
      new bytes(0)
    );

    require(gasEstimate <= address(this).balance, Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES);

    AXELAR_GAS_SERVICE.payGas{value: gasEstimate}(
      address(this),
      nativeChainId,
      Strings.toHexString(receiver),
      message,
      totalGasLimit,
      true,
      address(this),
      new bytes(0)
    );
    AXELAR_GATEWAY.callContract(nativeChainId, Strings.toHexString(receiver), message);

    return (address(AXELAR_GATEWAY), 0);
  }

  /// @inheritdoc IAxelarExecutable
  function execute(
    bytes32 commandId,
    string calldata sourceChain,
    string calldata sourceAddress,
    bytes calldata payload
  ) external {
    bytes32 payloadHash = keccak256(payload);

    require(
      AXELAR_GATEWAY.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash),
      Errors.INVALID_AXELAR_GATEWAY_CONTRACT_CALL
    );

    uint256 originChainId = axelarNativeToInfraChainId(sourceChain);
    address srcAddress = StringToAddress.stringToAddress(sourceAddress);
    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(payload, originChainId);
  }

  /// @inheritdoc IAxelarAdapter
  function axelarNativeToInfraChainId(
    string memory nativeChainId
  ) public pure virtual returns (uint256) {
    if (nativeChainId.equal('Ethereum')) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId.equal('Avalanche')) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId.equal('Polygon')) {
      return ChainIds.POLYGON;
    } else if (nativeChainId.equal('arbitrum')) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId.equal('optimism')) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId.equal('base')) {
      return ChainIds.BASE;
    } else if (nativeChainId.equal('binance')) {
      return ChainIds.BNB;
    } else if (nativeChainId.equal('scroll')) {
      return ChainIds.SCROLL;
    } else if (nativeChainId.equal('celo')) {
      return ChainIds.CELO;
    } else if (nativeChainId.equal('Fantom')) {
      return ChainIds.FANTOM;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IAxelarAdapter
  function axelarInfraToNativeChainId(
    uint256 infraChainId
  ) public pure virtual returns (string memory) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return 'Ethereum';
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return 'Avalanche';
    } else if (infraChainId == ChainIds.POLYGON) {
      return 'Polygon';
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return 'arbitrum';
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return 'optimism';
    } else if (infraChainId == ChainIds.FANTOM) {
      return 'Fantom';
    } else if (infraChainId == ChainIds.BASE) {
      return 'base';
    } else if (infraChainId == ChainIds.SCROLL) {
      return 'scroll';
    } else if (infraChainId == ChainIds.BNB) {
      return 'binance';
    } else if (infraChainId == ChainIds.CELO) {
      return 'celo';
    } else {
      return '';
    }
  }
}
