// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from 'solidity-utils/contracts/oz-common/SafeCast.sol';
import {IPolygonZkEVMBridge} from './interfaces/IPolygonZkEVMBridge.sol';
import {IBridgeMessageReceiver} from './interfaces/IBridgeMessageReceiver.sol';
import {IBaseAdapter, BaseAdapter} from '../BaseAdapter.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from '../../libs/ChainIds.sol';

/**
 * @title ZkEVMAdapter
 * @author BGD Labs
 * @notice ZkEVM bridge adapter. Used to send and receive messages cross chain between Ethereum and ZkEVM
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
abstract contract ZkEVMAdapter is BaseAdapter, IBridgeMessageReceiver {
  address public immutable ZK_EVM_BRIDGE;

  modifier onlyZkEVMBridge() {
    require(msg.sender == ZK_EVM_BRIDGE, Errors.CALLER_NOT_ZK_EVM_BRIDGE);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param zkEVMBridge address of the zkEVMBridge that will be used to send/receive messages to the root/child chain
   * @param baseGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address zkEVMBridge,
    uint256 baseGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, baseGasLimit, trustedRemotes) {
    ZK_EVM_BRIDGE = zkEVMBridge;
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );

    uint32 nativeChainId = SafeCast.toUint32(infraToNativeChainId(destinationChainId));
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    IPolygonZkEVMBridge(ZK_EVM_BRIDGE).bridgeMessage(nativeChainId, receiver, true, message);

    return (ZK_EVM_BRIDGE, 0);
  }

  /// @inheritdoc IBridgeMessageReceiver
  function onMessageReceived(
    address originalSender,
    uint32 originNetwork,
    bytes calldata message
  ) external payable override onlyZkEVMBridge {
    uint256 originChainId = nativeToInfraChainId(originNetwork);
    require(
      _trustedRemotes[originChainId] == originalSender && originalSender != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originChainId);
  }

  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool);

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(
    uint256 nativeChainId
  ) public pure virtual override returns (uint256) {
    if (nativeChainId == uint32(0)) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId == uint32(1)) {
      return ChainIds.POLYGON_ZK_EVM;
    }
    return 0;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(
    uint256 infraChainId
  ) public pure virtual override returns (uint256) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return uint32(0);
    } else if (infraChainId == ChainIds.POLYGON_ZK_EVM) {
      return uint32(1);
    }
    return type(uint32).max;
  }
}
