// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from '../../src/contracts/libs/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {ZkSyncAdapter, IZkSyncAdapter, IMailbox, IClOracle, IBaseAdapter, AddressAliasHelper} from '../../src/contracts/adapters/zkSync/ZkSyncAdapter.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';

contract ZkSyncAdapterTest is BaseAdapterTest {
  ZkSyncAdapter internal zkSyncAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setZkSyncAdapter(
    address crossChainController,
    address originForwarder,
    address mailBox,
    address clGasPriceOracle,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(crossChainController > address(65536));
    vm.assume(mailBox > address(65536));
    vm.assume(originForwarder > address(65536));
    vm.assume(clGasPriceOracle > address(65536));
    vm.assume(baseGasLimit < 1 ether);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(mailBox);
    _assumeSafeAddress(refundAddress);
    vm.assume(originForwarder != address(0));
    vm.assume(clGasPriceOracle != address(0));
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
      clGasPriceOracle,
      refundAddress,
      baseGasLimit,
      originConfigs
    );
    _;
  }

  function setUp() public {}

  function testWrongZkSyncMailbox(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
    address refundAddress,
    uint256 originChainId,
    address clGasPriceOracle
  ) public {
    vm.assume(crossChainController != address(0));
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);
    vm.assume(clGasPriceOracle != address(0));

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;
    vm.expectRevert(bytes(Errors.ZK_SYNC_MAILBOX_CANT_BE_ADDRESS_0));
    new ZkSyncAdapter(
      crossChainController,
      address(0),
      clGasPriceOracle,
      refundAddress,
      baseGasLimit,
      originConfigs
    );
  }

  function testWrongClOracle(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
    address refundAddress,
    uint256 originChainId,
    address mailbox
  ) public {
    vm.assume(crossChainController != address(0));
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);
    vm.assume(mailbox != address(0));

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;
    vm.expectRevert(bytes(Errors.CL_GAS_PRICE_ORACLE_CANT_BE_ADDRESS_0));
    new ZkSyncAdapter(
      crossChainController,
      mailbox,
      address(0),
      refundAddress,
      baseGasLimit,
      originConfigs
    );
  }

  function testInitialize(
    address crossChainController,
    address mailbox,
    address clGasPriceOracle,
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
      clGasPriceOracle,
      refundAddress,
      baseGasLimit,
      originChainId
    )
  {
    assertEq(zkSyncAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  struct Params {
    address mailbox;
    address clGasPriceOracle;
    address receiver;
    uint256 dstGasLimit;
    address caller;
  }

  function testForwardMessage(
    address crossChainController,
    address mailbox,
    address clGasPriceOracle,
    address originForwarder,
    address refundAddress
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      clGasPriceOracle,
      refundAddress,
      0,
      ChainIds.ETHEREUM
    )
  {
    _testForwardMessage(
      Params({
        mailbox: mailbox,
        clGasPriceOracle: clGasPriceOracle,
        receiver: address(135961),
        dstGasLimit: 12,
        caller: address(12354)
      })
    );
  }

  function testForwardMessageWhenNoValue(
    address crossChainController,
    address mailbox,
    address clGasPriceOracle,
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
      clGasPriceOracle,
      refundAddress,
      0,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));
    _testForwardMessageWhenNoValue(mailbox, clGasPriceOracle, receiver, dstGasLimit);
  }

  function testForwardMessageWhenChainNotSupported(
    address crossChainController,
    address mailbox,
    address clGasPriceOracle,
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
      clGasPriceOracle,
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
    address clGasPriceOracle,
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
      clGasPriceOracle,
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
    address clGasPriceOracle,
    address originForwarder,
    bytes memory message
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      clGasPriceOracle,
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
    address clGasPriceOracle,
    address originForwarder,
    address refundAddress,
    address remote
  )
    public
    setZkSyncAdapter(
      crossChainController,
      originForwarder,
      mailbox,
      clGasPriceOracle,
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

  function _testForwardMessageWhenNoValue(
    address mailbox,
    address clGasPriceOracle,
    address receiver,
    uint256 dstGasLimit
  ) internal {
    bytes memory message = abi.encode('test message');

    vm.mockCall(
      clGasPriceOracle,
      abi.encodeWithSelector(IClOracle.latestRoundData.selector),
      abi.encode(uint80(0), int256(123), 0, 0, uint80(0))
    );
    vm.mockCall(
      mailbox,
      abi.encodeWithSelector(IMailbox.l2TransactionBaseCost.selector),
      abi.encode(10)
    );
    vm.mockCall(
      mailbox,
      10,
      abi.encodeWithSelector(IMailbox.requestL2Transaction.selector),
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
      params.clGasPriceOracle,
      abi.encodeWithSelector(IClOracle.latestRoundData.selector),
      abi.encode(uint80(0), int256(123), 0, 0, uint80(0))
    );
    vm.mockCall(
      params.mailbox,
      abi.encodeWithSelector(IMailbox.l2TransactionBaseCost.selector),
      abi.encode(10)
    );
    vm.mockCall(
      params.mailbox,
      10,
      abi.encodeWithSelector(IMailbox.requestL2Transaction.selector),
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
