// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {ArbAdapter, IArbAdapter, AddressAliasHelper, IInbox} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

contract ArbAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant INBOX = address(12345);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  uint256 public constant ORIGIN_CHAIN_ID = ChainIds.ETHEREUM;
  address public constant ADDRESS_WITH_ETH = address(12301234);

  uint256 public constant BASE_GAS_LIMIT = 10_000;

  ArbAdapter public arbAdapter;

  IBaseAdapter.TrustedRemotesConfig internal originConfig =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: CROSS_CHAIN_CONTROLLER,
      originChainId: ORIGIN_CHAIN_ID
    });

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    arbAdapter = new ArbAdapter(
      CROSS_CHAIN_CONTROLLER,
      INBOX,
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      BASE_GAS_LIMIT,
      originConfigs
    );
  }

  function testInitialize() public {
    assertEq(
      keccak256(abi.encode(arbAdapter.adapterName())),
      keccak256(abi.encode('Arbitrum native adapter'))
    );
    assertEq(arbAdapter.getTrustedRemoteByChainId(ORIGIN_CHAIN_ID), CROSS_CHAIN_CONTROLLER);
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(arbAdapter.nativeToInfraChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(arbAdapter.infraToNativeChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  // function testForwardMessage() public {
  //   uint40 payloadId = uint40(0);
  //   bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
  //   uint32 dstGasLimit = 600000;
  //   uint256 maxSubmission = 2;
  //   bytes memory data = abi.encodeWithSelector(IArbAdapter.arbReceive.selector, message);

  //   hoax(ADDRESS_WITH_ETH, 10 ether);
  //   vm.mockCall(
  //     INBOX,
  //     abi.encodeWithSelector(
  //       IInbox.calculateRetryableSubmissionFee.selector,
  //       data.length,
  //       block.basefee + arbAdapter.BASE_FEE_MARGIN()
  //     ),
  //     abi.encode(maxSubmission)
  //   );
  //   vm.mockCall(
  //     INBOX,
  //     abi.encodeWithSelector(
  //       IInbox.createRetryableTicket.selector,
  //       RECEIVER_CROSS_CHAIN_CONTROLLER,
  //       0,
  //       maxSubmission,
  //       RECEIVER_CROSS_CHAIN_CONTROLLER,
  //       RECEIVER_CROSS_CHAIN_CONTROLLER,
  //       dstGasLimit + BASE_GAS_LIMIT,
  //       arbAdapter.L2_MAX_FEE_PER_GAS(),
  //       data
  //     ),
  //     abi.encode(1)
  //   );
  //   (bool success, bytes memory returnData) = address(arbAdapter).delegatecall(
  //     abi.encodeWithSelector(
  //       IBaseAdapter.forwardMessage.selector,
  //       RECEIVER_CROSS_CHAIN_CONTROLLER,
  //       dstGasLimit,
  //       ChainIds.ARBITRUM,
  //       message
  //     )
  //   );
  //   vm.clearMockedCalls();

  //   assertEq(success, true);
  //   assertEq(returnData, abi.encode(INBOX, 1));
  // }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    arbAdapter.forwardMessage(
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
    arbAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.ARBITRUM, message);
  }

  // function testForwardMessageWhenNotEnoughFunds() public {
  //   uint40 payloadId = uint40(0);
  //   bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
  //   uint32 dstGasLimit = 600000;
  //   uint256 maxSubmission = 2 ether;
  //   bytes memory data = abi.encodeWithSelector(IArbAdapter.arbReceive.selector, message);

  //   hoax(ADDRESS_WITH_ETH, 0 ether);
  //   vm.mockCall(
  //     INBOX,
  //     abi.encodeWithSelector(
  //       IInbox.calculateRetryableSubmissionFee.selector,
  //       data.length,
  //       block.basefee + arbAdapter.BASE_FEE_MARGIN()
  //     ),
  //     abi.encode(maxSubmission)
  //   );
  //   vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));
  //   arbAdapter.forwardMessage(
  //     RECEIVER_CROSS_CHAIN_CONTROLLER,
  //     dstGasLimit,
  //     ChainIds.ARBITRUM,
  //     message
  //   );
  //   vm.clearMockedCalls();
  // }

  function testArbReceive() public {
    bytes memory message = abi.encode('some message');
    address aliasCaller = AddressAliasHelper.applyL1ToL2Alias(CROSS_CHAIN_CONTROLLER);
    hoax(aliasCaller);
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
    arbAdapter.arbReceive(message);
  }

  function testArbReceiveWhenRemote_CallerNotTrusted() public {
    bytes memory message = abi.encode('some message');

    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    arbAdapter.arbReceive(message);
  }
}
