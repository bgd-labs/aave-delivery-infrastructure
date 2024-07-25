// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {SafeCast} from 'solidity-utils/contracts/oz-common/SafeCast.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {ICrossDomainMessenger} from '../../src/contracts/adapters/optimism/OpAdapter.sol';
import {MetisAdapter, IOpAdapter} from '../../src/contracts/adapters/metis/MetisAdapter.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

contract MetisAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(65536 + 123);
  address public constant CROSS_CHAIN_CONTROLLER = address(65536 + 1234);
  address public constant OVM_CROSS_DOMAIN_MESSENGER = address(65536 + 12345);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  uint256 public constant ORIGIN_CHAIN_ID = ChainIds.ETHEREUM;
  address public constant ADDRESS_WITH_ETH = address(12301234);
  uint256 public constant BASE_GAS_LIMIT = 10_000;

  MetisAdapter public metisAdapter;

  IBaseAdapter.TrustedRemotesConfig internal originConfig =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: ORIGIN_FORWARDER,
      originChainId: ORIGIN_CHAIN_ID
    });

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    metisAdapter = new MetisAdapter(
      CROSS_CHAIN_CONTROLLER,
      OVM_CROSS_DOMAIN_MESSENGER,
      BASE_GAS_LIMIT,
      originConfigs
    );
  }

  function testInitialize() public {
    assertEq(
      keccak256(abi.encode(metisAdapter.adapterName())),
      keccak256(abi.encode('Metis native adapter'))
    );
    assertEq(metisAdapter.getTrustedRemoteByChainId(ORIGIN_CHAIN_ID), ORIGIN_FORWARDER);
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(metisAdapter.nativeToInfraChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(metisAdapter.infraToNativeChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testForwardMessage() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      OVM_CROSS_DOMAIN_MESSENGER,
      abi.encodeWithSelector(
        ICrossDomainMessenger.sendMessageViaChainId.selector,
        ChainIds.METIS,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        abi.encodeWithSelector(IOpAdapter.ovmReceive.selector, message),
        SafeCast.toUint32(dstGasLimit + BASE_GAS_LIMIT)
      ),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(metisAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        RECEIVER_CROSS_CHAIN_CONTROLLER,
        dstGasLimit,
        ChainIds.METIS,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(OVM_CROSS_DOMAIN_MESSENGER, 0));
  }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    metisAdapter.forwardMessage(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
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
    metisAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.METIS, message);
  }

  function testOvmReceive() public {
    bytes memory message = abi.encode('some message');

    hoax(OVM_CROSS_DOMAIN_MESSENGER);
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
      OVM_CROSS_DOMAIN_MESSENGER,
      abi.encodeWithSelector(ICrossDomainMessenger.xDomainMessageSender.selector),
      abi.encode(ORIGIN_FORWARDER)
    );
    metisAdapter.ovmReceive(message);
  }

  function testOvmReceiveWhenCallerNotRouter() public {
    bytes memory message = abi.encode('some message');

    vm.expectRevert(bytes(Errors.CALLER_NOT_OVM));
    metisAdapter.ovmReceive(message);
  }

  function testOvmReceiveWhenRemoteNotTrusted() public {
    bytes memory message = abi.encode('some message');

    hoax(OVM_CROSS_DOMAIN_MESSENGER);

    vm.mockCall(
      OVM_CROSS_DOMAIN_MESSENGER,
      abi.encodeWithSelector(ICrossDomainMessenger.xDomainMessageSender.selector),
      abi.encode(address(120984))
    );
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    metisAdapter.ovmReceive(message);
  }
}
