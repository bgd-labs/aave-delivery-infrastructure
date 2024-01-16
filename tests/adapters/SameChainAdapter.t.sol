// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {SameChainAdapter, IBaseReceiverPortal, IBaseAdapter, Errors} from '../../src/contracts/adapters/sameChain/SameChainAdapter.sol';
import {Transaction, Envelope, TransactionUtils, EncodedEnvelope, EncodedTransaction} from '../../src/contracts/libs/EncodingUtils.sol';

contract SameChainAdapterTest is Test {
  address public ORIGIN = address(123);
  address public DESTINATION = address(1234);

  SameChainAdapter public sameChainAdapter;

  function setUp() public {
    sameChainAdapter = new SameChainAdapter();

    assertEq(
      keccak256(abi.encode(sameChainAdapter.adapterName())),
      keccak256(abi.encode('SameChain adapter'))
    );
  }

  function testForwardPayload() public {
    uint40 payloadId = uint40(0);
    bytes memory encodedMessage = abi.encode(payloadId);

    Envelope memory envelope = Envelope({
      nonce: 1,
      origin: ORIGIN,
      destination: DESTINATION,
      originChainId: block.chainid,
      destinationChainId: block.chainid,
      message: encodedMessage
    });
    EncodedEnvelope memory encodedEnvelope = envelope.encode();

    Transaction memory transaction = Transaction({nonce: 0, encodedEnvelope: encodedEnvelope.data});
    EncodedTransaction memory encodedTransaction = transaction.encode();

    vm.mockCall(
      DESTINATION,
      abi.encodeWithSelector(IBaseReceiverPortal.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      DESTINATION,
      abi.encodeWithSelector(
        IBaseReceiverPortal.receiveCrossChainMessage.selector,
        ORIGIN,
        block.chainid,
        encodedMessage
      )
    );
    (bool success, bytes memory returnData) = address(sameChainAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        DESTINATION,
        0,
        block.chainid,
        encodedTransaction.data
      )
    );

    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(DESTINATION, 0));
  }

  function testForwardPayloadWhenNotSameChain() public {
    uint40 payloadId = uint40(0);
    bytes memory encodedMessage = abi.encode(payloadId);

    Envelope memory envelope = Envelope({
      nonce: 1,
      origin: ORIGIN,
      destination: DESTINATION,
      originChainId: block.chainid,
      destinationChainId: block.chainid,
      message: encodedMessage
    });
    EncodedEnvelope memory encodedEnvelope = envelope.encode();

    Transaction memory transaction = Transaction({nonce: 0, encodedEnvelope: encodedEnvelope.data});
    EncodedTransaction memory encodedTransaction = transaction.encode();

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_NOT_SAME_AS_CURRENT_CHAIN));
    sameChainAdapter.forwardMessage(DESTINATION, 0, 137, encodedTransaction.data);

    vm.clearMockedCalls();
  }
}
