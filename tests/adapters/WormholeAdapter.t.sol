// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {WormholeAdapter, IBaseAdapter, IWormholeRelayer} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import {IWormholeAdapter} from '../../src/contracts/adapters/wormhole/IWormholeAdapter.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';

contract WormholeAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant WORMHOLE_RELAYER = address(12345);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  address public constant ADDRESS_WITH_ETH = address(12301234);

  uint256 public constant ORIGIN_WORMHOLE_CHAIN_ID = ChainIds.ETHEREUM;

  IBaseAdapter.TrustedRemotesConfig internal originConfig =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: ORIGIN_FORWARDER,
      originChainId: ORIGIN_WORMHOLE_CHAIN_ID
    });

  WormholeAdapter internal wormholeAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    wormholeAdapter = new WormholeAdapter(
      CROSS_CHAIN_CONTROLLER,
      WORMHOLE_RELAYER,
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      originConfigs
    );
  }

  function testInitialize() public {
    assertEq(wormholeAdapter.getTrustedRemoteByChainId(ORIGIN_WORMHOLE_CHAIN_ID), ORIGIN_FORWARDER);
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(wormholeAdapter.nativeToInfraChainId(uint16(2)), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(wormholeAdapter.infraToNativeChainId(ChainIds.ETHEREUM), uint16(2));
  }

  function testForwardMessage() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;
    uint64 sequence = uint64(1);
    uint256 cost = 123;

    hoax(ADDRESS_WITH_ETH, 10 ether);

    vm.mockCall(
      WORMHOLE_RELAYER,
      abi.encodeWithSelector(IWormholeRelayer.quoteEVMDeliveryPrice.selector),
      abi.encode(cost, 0)
    );
    vm.mockCall(
      WORMHOLE_RELAYER,
      cost,
      abi.encodeWithSelector(IWormholeRelayer.sendPayloadToEvm.selector),
      abi.encode(sequence)
    );
    (bool success, bytes memory returnData) = address(wormholeAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        dstGasLimit,
        ChainIds.POLYGON,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(WORMHOLE_RELAYER, sequence));
  }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    wormholeAdapter.forwardMessage(RECEIVER_CROSS_CHAIN_CONTROLLER, dstGasLimit, 11, message);
  }

  function testForwardMessageWhenWrongReceiver() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    wormholeAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.POLYGON, message);
  }

  function testReceive() public {
    bytes memory message = abi.encode('some message');

    bytes32 sourceAddress = bytes32(uint256(uint160(ORIGIN_FORWARDER)));
    uint16 sourceChainId = uint16(2);

    hoax(WORMHOLE_RELAYER);
    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      CROSS_CHAIN_CONTROLLER,
      0,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector, message, 1)
    );
    wormholeAdapter.receiveWormholeMessages(
      message,
      new bytes[](0),
      sourceAddress,
      sourceChainId,
      bytes32(0)
    );
  }

  function testReceiveWhenCallerNotRouter(uint16 sourceChainId) public {
    bytes memory message = abi.encode('some message');
    bytes32 sourceAddress = bytes32(uint256(uint160(ORIGIN_FORWARDER)));

    vm.expectRevert(bytes(Errors.CALLER_NOT_WORMHOLE_RELAYER));

    wormholeAdapter.receiveWormholeMessages(
      message,
      new bytes[](0),
      sourceAddress,
      sourceChainId,
      bytes32(0)
    );
  }

  function testReceiveWhenRemoteNotTrusted(uint16 sourceChainId) public {
    bytes memory message = abi.encode('some message');

    hoax(WORMHOLE_RELAYER);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    wormholeAdapter.receiveWormholeMessages(
      message,
      new bytes[](0),
      bytes32(uint256(uint160(1241151))),
      sourceChainId,
      bytes32(0)
    );
  }
}
