// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {Transaction, Envelope, EncodedEnvelope, EncodedTransaction, TransactionUtils, EnvelopeUtils} from '../../src/contracts/libs/EncodingUtils.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {ZkSyncAdapter, IZkSyncAdapter, IBridgehub, IBaseAdapter, AddressAliasHelper} from '../../src/contracts/adapters/zkSync/ZkSyncAdapter.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';

contract ZkSyncAdapterTest is BaseAdapterTest {
  ZkSyncAdapter internal zkSyncAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setZkSyncAdapter(
    address crossChainController,
    address originForwarder,
    address mailBox,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(crossChainController != tx.origin); // zkVM doesn't support mocking tx.origin
    vm.assume(baseGasLimit < 1 ether);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(mailBox);
    _assumeSafeAddress(refundAddress);
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    zkSyncAdapter = new ZkSyncAdapter(
      crossChainController,
      mailBox,
      refundAddress,
      baseGasLimit,
      originConfigs
    );
    _;
  }

  function setUp() public {}

  function testUndoAlias() public {
    address aliased = 0x91Bbb474eE7E3a04A4eE77bE874bcCEaA01b342a;
    address unaliased = AddressAliasHelper.undoL1ToL2Alias(aliased);
    console.log('unaliased', unaliased);
  }

  function testWrongZkSyncMailbox(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
    address refundAddress,
    uint256 originChainId
  ) public {
    vm.assume(crossChainController != address(0));
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;
    vm.expectRevert(bytes(Errors.ZK_SYNC_BRIDGEHUB_CANT_BE_ADDRESS_0));
    new ZkSyncAdapter(crossChainController, address(0), refundAddress, baseGasLimit, originConfigs);
  }

  function testInitialize(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      baseGasLimit,
      originChainId
    )
  {
    assertEq(zkSyncAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  struct Params {
    address mailbox;
    address receiver;
    uint256 dstGasLimit;
    address caller;
  }

  function testForwardMessage(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      0,
      ChainIds.ETHEREUM
    )
  {
    _testForwardMessage(
      Params({mailbox: mailbox, receiver: address(135961), dstGasLimit: 12, caller: address(12354)})
    );
  }

  function testForwardMessageWhenNoValue(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      0,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));
    _testForwardMessageWhenNoValue(mailbox, receiver, dstGasLimit);
  }

  function testForwardMessageWhenChainNotSupported(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver,
    bytes memory message
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    zkSyncAdapter.forwardMessage(receiver, dstGasLimit, 11, message);
  }

  function testForwardMessageWhenWrongReceiver(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    bytes memory message
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    zkSyncAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.ZK_SYNC, message);
  }

  function testReceive(
    address crossChainController,
    address mailbox,
    address originForwarder,
    bytes memory message
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      address(125),
      0,
      ChainIds.ETHEREUM
    )
  {
    hoax(AddressAliasHelper.applyL1ToL2Alias(originForwarder));
    vm.mockCall(
      crossChainController,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      crossChainController,
      0,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector, message, 1)
    );
    zkSyncAdapter.receiveMessage(message);
  }

  function testReceiveWhenRemoteNotTrusted(
    address crossChainController,
    address mailbox,
    address originForwarder,
    address refundAddress,
    address remote
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      refundAddress,
      0,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(remote != originForwarder);

    hoax(AddressAliasHelper.applyL1ToL2Alias(remote));
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    zkSyncAdapter.receiveMessage(abi.encode('test message'));
  }

  // test of deployed infra in zksync sepolia
  event TestWorked(address indexed originSender, uint256 indexed originChainId, bytes message);
  event TransactionReceived(
    bytes32 transactionId,
    bytes32 indexed envelopeId,
    uint256 indexed originChainId,
    Transaction transaction,
    address indexed bridgeAdapter,
    uint8 confirmations
  );
  event EnvelopeDeliveryAttempted(bytes32 envelopeId, Envelope envelope, bool isDelivered);

  function test_receiveMessage() public {
    vm.createSelectFork('https://sepolia.era.zksync.dev', 2627064);

    bytes
      memory message = hex'0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000120000000000000000000000006d603081563784db3f83ef1f65cc389d94365ac90000000000000000000000003676a657f22ea4a6eb3a51da7233a37e8d6049670000000000000000000000000000000000000000000000000000000000aa36a7000000000000000000000000000000000000000000000000000000000000012c00000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000013736f6d652072616e646f6d206d65737361676500000000000000000000000000';

    Transaction memory transaction = TransactionUtils.decode(message);
    Envelope memory envelope = transaction.getEnvelope();
    bytes32 txId = TransactionUtils.getId(transaction);
    bytes32 envelopeId = EnvelopeUtils.getId(envelope);

    address crossChainReceiver = 0x77430FCd47F62A9706CAca6300563c6B27885F5F;
    address zkSyncAdapter = 0x013D88537bFdb7984700D44a8c0427D13d352D90;
    // config checks
    bool allowed = ICrossChainReceiver(crossChainReceiver).isReceiverBridgeAdapterAllowed(
      zkSyncAdapter,
      11155111
    );
    assertEq(allowed, true);

    // call adapter contract with real tx data
    hoax(0x91Bbb474eE7E3a04A4eE77bE874bcCEaA01b342a); // aliased origin of 0x80Aab474ee7e3A04A4ee77Be874bCCEAA01B2319 (crossChainController on sepolia)
    vm.expectEmit(true, true, true, true);
    emit TransactionReceived(
      txId,
      envelopeId,
      envelope.originChainId,
      transaction,
      zkSyncAdapter,
      1
    );
    vm.expectEmit(true, true, true, true);
    emit TestWorked(envelope.origin, envelope.originChainId, envelope.message);
    vm.expectEmit(true, true, true, true);
    emit EnvelopeDeliveryAttempted(envelopeId, envelope, true);
    ZkSyncAdapter(zkSyncAdapter).receiveMessage(message);

    // check state after tx
    bool received = ICrossChainReceiver(crossChainReceiver).isTransactionReceivedByAdapter(
      txId,
      zkSyncAdapter
    );
    assertEq(received, true);

    ICrossChainReceiver.EnvelopeState state = ICrossChainReceiver(crossChainReceiver)
      .getEnvelopeState(envelopeId);
    assertEq(uint256(state), 2);
  }

  function _testForwardMessageWhenNoValue(
    address mailbox,
    address receiver,
    uint256 dstGasLimit
  ) internal {
    bytes memory message = abi.encode('test message');

    vm.mockCall(
      mailbox,
      abi.encodeWithSelector(IBridgehub.l2TransactionBaseCost.selector),
      abi.encode(10)
    );
    vm.mockCall(
      mailbox,
      10,
      abi.encodeWithSelector(IBridgehub.requestL2TransactionDirect.selector),
      abi.encode(bytes32('test'))
    );
    vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));

    (bool success, ) = address(zkSyncAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        receiver,
        dstGasLimit,
        ChainIds.ZK_SYNC,
        message
      )
    );
    assertEq(success, false);
  }

  function _testForwardMessage(Params memory params) internal {
    bytes memory message = abi.encode('test message');

    hoax(params.caller, 10 ether);

    vm.mockCall(
      params.mailbox,
      abi.encodeWithSelector(IBridgehub.l2TransactionBaseCost.selector),
      abi.encode(10)
    );
    vm.mockCall(
      params.mailbox,
      10,
      abi.encodeWithSelector(IBridgehub.requestL2TransactionDirect.selector),
      abi.encode(bytes32('test'))
    );
    (bool success, bytes memory returnData) = address(zkSyncAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        params.receiver,
        params.dstGasLimit,
        ChainIds.ZK_SYNC,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(params.mailbox, bytes32('test')));
  }
}
