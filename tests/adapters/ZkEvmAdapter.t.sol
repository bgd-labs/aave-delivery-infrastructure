// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';
import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';
import {IPolygonZkEVMBridge} from '../../src/contracts/adapters/zkEVM/interfaces/IPolygonZkEVMBridge.sol';

contract ZkEvmAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  address public constant ZK_EVM_BRIDGE = address(12345678);
  uint256 public constant ORIGIN_CHAIN_ID = ChainIds.ETHEREUM;
  uint256 public constant DESTINATION_CHAIN_ID = ChainIds.POLYGON_ZK_EVM;
  address public constant ADDRESS_WITH_ETH = address(12301234);
  uint256 public constant BASE_GAS_LIMIT = 10_000;

  ZkEVMAdapterEthereum public zkEvmAdapterEthereum;
  ZkEVMAdapterPolygonZkEVM public zkEvmAdapterPolygonZkEvm;

  IBaseAdapter.TrustedRemotesConfig internal originConfigPolygonZkEVM =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: CROSS_CHAIN_CONTROLLER,
      originChainId: ORIGIN_CHAIN_ID
    });

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigsEthereum = new IBaseAdapter.TrustedRemotesConfig[](0);

    zkEvmAdapterEthereum = new ZkEVMAdapterEthereum(
      CROSS_CHAIN_CONTROLLER,
      ZK_EVM_BRIDGE,
      BASE_GAS_LIMIT,
      originConfigsEthereum
    );

    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigsPolygon = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigsPolygon[0] = originConfigPolygonZkEVM;

    zkEvmAdapterPolygonZkEvm = new ZkEVMAdapterPolygonZkEVM(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      ZK_EVM_BRIDGE,
      BASE_GAS_LIMIT,
      originConfigsPolygon
    );
  }

  function testInitialize() public {
    assertEq(
      zkEvmAdapterPolygonZkEvm.getTrustedRemoteByChainId(ORIGIN_CHAIN_ID),
      CROSS_CHAIN_CONTROLLER
    );
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(zkEvmAdapterEthereum.nativeToInfraChainId(0), ChainIds.ETHEREUM);
    assertEq(zkEvmAdapterEthereum.nativeToInfraChainId(1), ChainIds.POLYGON_ZK_EVM);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(zkEvmAdapterPolygonZkEvm.infraToNativeChainId(ChainIds.ETHEREUM), 0);
    assertEq(zkEvmAdapterPolygonZkEvm.infraToNativeChainId(ChainIds.POLYGON_ZK_EVM), 1);
  }

  function testForwardMessageToPolygonZkEVM() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      ZK_EVM_BRIDGE,
      abi.encodeWithSelector(
        IPolygonZkEVMBridge.bridgeMessage.selector,
        1,
        address(zkEvmAdapterPolygonZkEvm),
        true,
        message
      ),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(zkEvmAdapterEthereum).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        address(zkEvmAdapterPolygonZkEvm),
        dstGasLimit,
        ChainIds.POLYGON_ZK_EVM,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(ZK_EVM_BRIDGE, 0));
  }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    zkEvmAdapterEthereum.forwardMessage(
      address(zkEvmAdapterPolygonZkEvm),
      dstGasLimit,
      ChainIds.ETHEREUM,
      message
    );
  }

  function testForwardMessageWhenWrongReceiver() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    zkEvmAdapterEthereum.forwardMessage(address(0), dstGasLimit, ChainIds.POLYGON_ZK_EVM, message);
  }

  function testProcessMessageFromBridge() public {
    bytes memory message = abi.encode('some message');
    vm.mockCall(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      0,
      abi.encodeWithSelector(
        ICrossChainReceiver.receiveCrossChainMessage.selector,
        message,
        ORIGIN_CHAIN_ID
      )
    );
    hoax(ZK_EVM_BRIDGE);
    zkEvmAdapterPolygonZkEvm.onMessageReceived(CROSS_CHAIN_CONTROLLER, uint32(0), message);
  }

  function testProcessMessageWhenCallerNotBridge() public {
    bytes memory message = abi.encode('some message');
    vm.expectRevert(bytes(Errors.CALLER_NOT_ZK_EVM_BRIDGE));
    zkEvmAdapterEthereum.onMessageReceived(CROSS_CHAIN_CONTROLLER, uint32(1), message);

    vm.expectRevert(bytes(Errors.CALLER_NOT_ZK_EVM_BRIDGE));
    zkEvmAdapterPolygonZkEvm.onMessageReceived(CROSS_CHAIN_CONTROLLER, uint32(0), message);
  }

  function testReceiveWhenRemote_CallerNotTrusted() public {
    bytes memory message = abi.encode('some message');

    hoax(ZK_EVM_BRIDGE);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    zkEvmAdapterEthereum.onMessageReceived(address(0x4546b), uint32(1), message);

    hoax(ZK_EVM_BRIDGE);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    zkEvmAdapterPolygonZkEvm.onMessageReceived(address(0x4546b), uint32(0), message);
  }
}
