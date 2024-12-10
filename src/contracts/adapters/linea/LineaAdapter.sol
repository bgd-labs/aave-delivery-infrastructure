// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IMessageService} from './interfaces/IMessageService.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {Errors} from '../../libs/Errors.sol';
import {ILineaAdapter} from './ILineaAdapter.sol';
import {SafeCast} from 'solidity-utils/contracts/oz-common/SafeCast.sol';

/**
 * @title LineaAdapter
 * @author BGD Labs
 * @notice Optimism bridge adapter. Used to send and receive messages cross chain between Ethereum and Optimism
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 * @dev note that this adapter is can only be used for the communication path ETHEREUM -> LINEA
 */
contract LineaAdapter is ILineaAdapter, BaseAdapter {
  /// @inheritdoc ILineaAdapter
  address public immutable LINEA_MESSAGE_SERVICE;

  /**
   * @notice only calls from the set ovm are accepted.
   */
  modifier onlyLineaMessageService() {
    require(msg.sender == address(LINEA_MESSAGE_SERVICE), Errors.CALLER_NOT_LINEA_MESSAGE_SERVICE);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param lineaMessageService Linea entry point address
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param adapterName string indicating the adapter name
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address lineaMessageService,
    uint256 providerGasLimit,
    string memory adapterName,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, adapterName, trustedRemotes) {
    LINEA_MESSAGE_SERVICE = lineaMessageService;
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external virtual returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    // @dev we set _fee to 0 because for now we will do the claim manually. Until an automated way of getting the
    // price is implemented by Linea
    IMessageService(LINEA_MESSAGE_SERVICE).sendMessage(
      receiver,
      0,
      abi.encodeWithSelector(ILineaAdapter.receiveMessage.selector, message)
    );
    return (LINEA_MESSAGE_SERVICE, 0);
  }

  /// @inheritdoc ILineaAdapter
  function ovmReceive(bytes calldata message) external onlyLineaMessageService {
    uint256 originChainId = getOriginChainId();
    address srcAddress = IMessageService(LINEA_MESSAGE_SERVICE).sender();
    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originChainId);
  }

  /// @inheritdoc ILineaAdapter
  function getOriginChainId() public pure virtual returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  /// @inheritdoc ILineaAdapter
  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool) {
    return chainId == ChainIds.LINEA;
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
