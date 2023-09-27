// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPolygonZkEVMBridge} from './interfaces/IPolygonZkEVMBridge.sol';
import {IBridgeMessageReceiver} from './interfaces/IBridgeMessageReceiver.sol';
import {IBaseAdapter, BaseAdapter} from '../BaseAdapter.sol';
import {Errors} from '../../libs/Errors.sol';

abstract contract ZkEVMAdapter is BaseAdapter, IBridgeMessageReceiver {
  address public immutable ZK_EVM_BRIDGE;

  modifier onlyZkEVMBridge() {
    require(msg.sender == ZK_EVM_BRIDGE, Errors.CALLER_NOT_ZK_EVM_BRIDGE);
    _;
  }

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param zkEVMBridge address of the zkEVMBridge that will be used to send/receive messages to the root/child chain
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address zkEVMBridge,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, trustedRemotes) {
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
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    IPolygonZkEVMBridge(ZK_EVM_BRIDGE).bridgeMessage(
      uint32(destinationChainId),
      receiver,
      true, // don't fully understand this flag forceUpdateGlobalExitRoot,
      message
    );

    return (ZK_EVM_BRIDGE, 0);
  }

  /// @inheritdoc IBridgeMessageReceiver
  function onMessageReceived(
    address originalSender,
    uint32 originNetwork,
    bytes calldata message
  ) external payable override onlyZkEVMBridge {
    require(
      _trustedRemotes[originNetwork] == originalSender && originalSender != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originNetwork);
  }

  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool);

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }
}
