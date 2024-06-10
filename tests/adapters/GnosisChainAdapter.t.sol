// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {GnosisChainAdapter, IGnosisChainAdapter, IArbitraryMessageBridge} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

contract GnosisChainAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant GNOSIS_AMB_BRIDGE = address(12345);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  uint256 public constant ORIGIN_CHAIN_ID = ChainIds.ETHEREUM;
  address public constant ADDRESS_WITH_ETH = address(12301234);

  GnosisChainAdapter public gnosisChainAdapter;

  uint256 public constant BASE_GAS_LIMIT = 10_000;

  IBaseAdapter.TrustedRemotesConfig internal originConfig =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: ORIGIN_FORWARDER,
      originChainId: ORIGIN_CHAIN_ID
    });

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    gnosisChainAdapter = new GnosisChainAdapter(
      CROSS_CHAIN_CONTROLLER,
      GNOSIS_AMB_BRIDGE,
      BASE_GAS_LIMIT,
      originConfigs
    );
  }

  function testInitialize() public {
    assertEq(
      keccak256(abi.encode(gnosisChainAdapter.adapterName())),
      keccak256(abi.encode('Gnosis native adapter'))
    );
    assertEq(gnosisChainAdapter.getTrustedRemoteByChainId(ORIGIN_CHAIN_ID), ORIGIN_FORWARDER);
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(gnosisChainAdapter.nativeToInfraChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(gnosisChainAdapter.infraToNativeChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testZeroBridgeAddress() public {
    vm.expectRevert(bytes(Errors.ZERO_GNOSIS_ARBITRARY_MESSAGE_BRIDGE));
    gnosisChainAdapter = new GnosisChainAdapter(
      CROSS_CHAIN_CONTROLLER,
      address(0),
      BASE_GAS_LIMIT,
      new IBaseAdapter.TrustedRemotesConfig[](0)
    );
  }

  function testForwardMessage() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      GNOSIS_AMB_BRIDGE,
      abi.encodeWithSelector(
        IArbitraryMessageBridge.requireToPassMessage.selector,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        abi.encodeWithSelector(IGnosisChainAdapter.receiveMessage.selector, message),
        dstGasLimit + BASE_GAS_LIMIT
      ),
      abi.encode(bytes32(uint256(uint160(RECEIVER_CROSS_CHAIN_CONTROLLER))))
    );
    (bool success, bytes memory returnData) = address(gnosisChainAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        dstGasLimit,
        ChainIds.GNOSIS,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(GNOSIS_AMB_BRIDGE, 0));
  }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encodeWithSelector(
      IGnosisChainAdapter.receiveMessage.selector,
      abi.encode(payloadId, CROSS_CHAIN_CONTROLLER)
    );
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    gnosisChainAdapter.forwardMessage(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      dstGasLimit,
      ChainIds.ETHEREUM,
      message
    );
  }

  function testForwardMessageWhenWrongReceiver() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encodeWithSelector(
      IGnosisChainAdapter.receiveMessage.selector,
      abi.encode(payloadId, CROSS_CHAIN_CONTROLLER)
    );
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    gnosisChainAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.GNOSIS, message);
  }

  function testReceiveMessage() public {
    bytes memory message = abi.encodeWithSelector(
      IGnosisChainAdapter.receiveMessage.selector,
      'some message'
    );

    hoax(GNOSIS_AMB_BRIDGE);
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
    vm.mockCall(
      GNOSIS_AMB_BRIDGE,
      abi.encodeWithSelector(IArbitraryMessageBridge.messageSender.selector),
      abi.encode(ORIGIN_FORWARDER)
    );
    vm.mockCall(
      GNOSIS_AMB_BRIDGE,
      abi.encodeWithSelector(IArbitraryMessageBridge.messageSourceChainId.selector),
      abi.encode(ChainIds.ETHEREUM)
    );

    gnosisChainAdapter.receiveMessage(message);
  }

  function testReceiveMessageWhenCallerNotRouter() public {
    bytes memory message = abi.encodeWithSelector(
      IGnosisChainAdapter.receiveMessage.selector,
      'some message'
    );

    vm.expectRevert(bytes(Errors.CALLER_NOT_GNOSIS_ARBITRARY_MESSAGE_BRIDGE));
    gnosisChainAdapter.receiveMessage(message);
  }

  function testReceiveMessageWhenRemoteNotTrusted() public {
    bytes memory message = abi.encodeWithSelector(
      IGnosisChainAdapter.receiveMessage.selector,
      'some message'
    );

    hoax(GNOSIS_AMB_BRIDGE);

    vm.mockCall(
      GNOSIS_AMB_BRIDGE,
      abi.encodeWithSelector(IArbitraryMessageBridge.messageSender.selector),
      abi.encode(address(120984))
    );
    vm.mockCall(
      GNOSIS_AMB_BRIDGE,
      abi.encodeWithSelector(IArbitraryMessageBridge.messageSourceChainId.selector),
      abi.encode(ChainIds.ETHEREUM)
    );
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    gnosisChainAdapter.receiveMessage(message);
  }
}
