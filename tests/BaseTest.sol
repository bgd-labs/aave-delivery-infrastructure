// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';
import {Transaction, EncodedTransaction, Envelope, EncodedEnvelope} from '../src/contracts/libs/EncodingUtils.sol';
import {ICrossChainForwarder} from '../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from '../src/contracts/interfaces/ICrossChainReceiver.sol';
import {CrossChainController, ICrossChainController} from '../src/contracts/CrossChainController.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../src/contracts/CrossChainControllerWithEmergencyMode.sol';

contract BaseTest is Test {
  bytes internal constant MESSAGE = bytes('this is the message to send');

  modifier executeAs(address executor) {
    vm.startPrank(executor);
    _;
    vm.stopPrank();
  }

  modifier filterAddress(address addressToFilter) {
    vm.assume(
      addressToFilter != 0xCe71065D4017F316EC606Fe4422e11eB2c47c246 && // FuzzerDict
        addressToFilter != 0x4e59b44847b379578588920cA78FbF26c0B4956C && // CREATE2 Factory (?)
        addressToFilter != 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84 && // address(this)
        addressToFilter != 0x185a4dc360CE69bDCceE33b3784B0282f7961aea && // ???
        addressToFilter != 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D // cheat codes
    );
    _;
  }

  struct ExtendedTransaction {
    bytes32 envelopeId;
    Envelope envelope;
    bytes envelopeEncoded;
    bytes32 transactionId;
    Transaction transaction;
    bytes transactionEncoded;
  }

  struct TestParams {
    address destination;
    address origin;
    uint256 originChainId;
    uint256 destinationChainId;
    uint256 transactionNonce;
    uint256 envelopeNonce;
  }

  modifier generateEmergencyState() {
    _;
  }

  modifier generateRetryTxState(
    address cccOwner,
    address ccc,
    uint256 destinationChainId,
    address destination,
    uint256 gasLimit
  ) {
    // set caller as an approved sender
    address[] memory senders = new address[](1);
    senders[0] = address(this);

    vm.startPrank(cccOwner);
    ICrossChainForwarder(ccc).approveSenders(senders);
    vm.stopPrank();

    // call forward message
    ICrossChainForwarder(ccc).forwardMessage(destinationChainId, destination, gasLimit, MESSAGE);
    _;
  }

  function _generateExtendedTransaction(
    TestParams memory testParams
  ) internal pure returns (ExtendedTransaction memory) {
    ExtendedTransaction memory extendedTx;

    extendedTx.envelope = Envelope({
      nonce: testParams.envelopeNonce,
      origin: testParams.origin,
      destination: testParams.destination,
      originChainId: testParams.originChainId,
      destinationChainId: testParams.destinationChainId,
      message: MESSAGE
    });
    EncodedEnvelope memory encodedEnvelope = extendedTx.envelope.encode();
    extendedTx.envelopeEncoded = encodedEnvelope.data;
    extendedTx.envelopeId = encodedEnvelope.id;

    extendedTx.transaction = Transaction({
      nonce: testParams.transactionNonce,
      encodedEnvelope: extendedTx.envelopeEncoded
    });
    EncodedTransaction memory encodedTransaction = extendedTx.transaction.encode();
    extendedTx.transactionEncoded = encodedTransaction.data;
    extendedTx.transactionId = encodedTransaction.id;

    return extendedTx;
  }
}
