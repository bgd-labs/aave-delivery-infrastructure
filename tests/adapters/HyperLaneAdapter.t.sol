// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {HyperLaneAdapter, IHyperLaneAdapter, IMailbox, IInterchainGasPaymaster} from '../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';
import {TypeCasts} from 'hyperlane-monorepo/libs/TypeCasts.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';

contract HyperLaneAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant MAIL_BOX = address(12345);
  address public constant IGP = address(123456);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  address public constant ADDRESS_WITH_ETH = address(12301234);

  uint256 public constant ORIGIN_HL_CHAIN_ID = ChainIds.ETHEREUM;
  uint256 public constant BASE_GAS_LIMIT = 10_000;

  HyperLaneAdapter public hlAdapter;

  IBaseAdapter.TrustedRemotesConfig internal originConfig =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: ORIGIN_FORWARDER,
      originChainId: ORIGIN_HL_CHAIN_ID
    });

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    hlAdapter = new HyperLaneAdapter(
      CROSS_CHAIN_CONTROLLER,
      MAIL_BOX,
      IGP,
      BASE_GAS_LIMIT,
      originConfigs
    );
  }

  function testInitialize() public {
    assertEq(
      keccak256(abi.encode(hlAdapter.getAdapterName())),
      keccak256(abi.encode('Hyperlane adapter'))
    );
    assertEq(hlAdapter.getTrustedRemoteByChainId(ORIGIN_HL_CHAIN_ID), ORIGIN_FORWARDER);
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(hlAdapter.nativeToInfraChainId(uint32(ChainIds.POLYGON)), ChainIds.POLYGON);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(hlAdapter.infraToNativeChainId(ChainIds.POLYGON), uint32(ChainIds.POLYGON));
  }

  function testForwardMessage() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;
    bytes32 messageId = keccak256(abi.encode(1));
    uint32 nativeChainId = uint32(ChainIds.POLYGON);

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      MAIL_BOX,
      abi.encodeWithSelector(IMailbox.dispatch.selector),
      abi.encode(messageId)
    );
    vm.mockCall(
      IGP,
      abi.encodeWithSelector(
        IInterchainGasPaymaster.quoteGasPayment.selector,
        nativeChainId,
        dstGasLimit + BASE_GAS_LIMIT
      ),
      abi.encode(10)
    );
    vm.mockCall(
      IGP,
      10,
      abi.encodeWithSelector(
        IInterchainGasPaymaster.payForGas.selector,
        messageId,
        nativeChainId,
        dstGasLimit + BASE_GAS_LIMIT,
        ADDRESS_WITH_ETH
      ),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(hlAdapter).delegatecall(
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
    assertEq(returnData, abi.encode(MAIL_BOX, messageId));
  }

  function testForwardMessageWithNoValue() public {
    uint40 payloadId = uint40(0);
    bytes memory payload = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);

    vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));
    (bool success, ) = address(hlAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        0,
        ChainIds.POLYGON,
        payload
      )
    );
    assertEq(success, false);
  }

  function testForwardMessageWhenWrongReceiver() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    HyperLaneAdapter(address(hlAdapter)).forwardMessage(
      address(0),
      dstGasLimit,
      ChainIds.POLYGON,
      message
    );
  }

  function testHandle() public {
    uint32 originChain = uint32(1);
    bytes memory message = abi.encode('some message');

    hoax(MAIL_BOX);
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
    HyperLaneAdapter(address(hlAdapter)).handle(
      originChain,
      TypeCasts.addressToBytes32(ORIGIN_FORWARDER),
      message
    );
  }

  function testHandleWhenCallerNotMailBox() public {
    uint32 originChain = uint32(1);
    bytes memory message = abi.encode('some message');

    vm.expectRevert(bytes(Errors.CALLER_NOT_HL_MAILBOX));
    HyperLaneAdapter(address(hlAdapter)).handle(
      originChain,
      TypeCasts.addressToBytes32(ORIGIN_FORWARDER),
      message
    );
  }

  function testHandleWhenWrongSrcAddress(uint32 originChain, address addr) public {
    bytes memory message = abi.encode('some message');

    hoax(MAIL_BOX);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    HyperLaneAdapter(address(hlAdapter)).handle(
      originChain,
      TypeCasts.addressToBytes32(addr),
      message
    );
  }
}
