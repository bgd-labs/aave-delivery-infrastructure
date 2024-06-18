// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {HyperLaneAdapter, IHyperLaneAdapter, IMailbox, TypeCasts, StandardHookMetadata} from '../../src/contracts/adapters/hyperLane/HyperLaneAdapter.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';

contract HyperLaneAdapterTest is BaseAdapterTest {
  HyperLaneAdapter public hlAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setHLAdapter(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(baseGasLimit < 1e7);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(mailBox);
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    hlAdapter = new HyperLaneAdapter(crossChainController, mailBox, baseGasLimit, originConfigs);
    _;
  }

  function setUp() public {}

  function testWrongMailBox(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
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
    vm.expectRevert(bytes(Errors.INVALID_HL_MAILBOX));
    new HyperLaneAdapter(crossChainController, address(0), baseGasLimit, originConfigs);
  }

  function testInitialize(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, originChainId)
  {
    assertEq(
      keccak256(abi.encode(hlAdapter.adapterName())),
      keccak256(abi.encode('Hyperlane adapter'))
    );
    assertEq(hlAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  function testGetInfraChainFromBridgeChain(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, originChainId)
  {
    assertEq(hlAdapter.nativeToInfraChainId(uint32(ChainIds.POLYGON)), ChainIds.POLYGON);
  }

  function testGetBridgeChainFromInfraChain(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, originChainId)
  {
    assertEq(hlAdapter.infraToNativeChainId(ChainIds.POLYGON), uint32(ChainIds.POLYGON));
  }

  function testForwardMessage(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver,
    address caller
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.POLYGON)
  {
    vm.assume(caller != address(0));
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    _testForwardMessage(mailBox, receiver, dstGasLimit, baseGasLimit, caller);
  }

  function testForwardMessageWithNoValue(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.POLYGON)
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    bytes memory message = abi.encode('test message');

    vm.mockCall(mailBox, abi.encodeWithSelector(IMailbox.quoteDispatch.selector), abi.encode(1e4));
    vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));
    (bool success, ) = address(hlAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        receiver,
        dstGasLimit,
        ChainIds.POLYGON,
        message
      )
    );
    assertEq(success, false);
  }

  function testForwardMessageWhenWrongReceiver(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 dstGasLimit
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.POLYGON)
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);
    bytes memory message = abi.encode('test message');

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    HyperLaneAdapter(address(hlAdapter)).forwardMessage(
      address(0),
      dstGasLimit,
      ChainIds.POLYGON,
      message
    );
  }

  function testHandle(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.ETHEREUM)
  {
    bytes memory message = abi.encode('some message');

    hoax(mailBox);
    vm.mockCall(
      crossChainController,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      crossChainController,
      0,
      abi.encodeWithSelector(
        ICrossChainReceiver.receiveCrossChainMessage.selector,
        message,
        ChainIds.ETHEREUM
      )
    );
    HyperLaneAdapter(address(hlAdapter)).handle(
      uint32(ChainIds.ETHEREUM),
      TypeCasts.addressToBytes32(originForwarder),
      message
    );
  }

  function testHandleWhenCallerNotMailBox(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    address caller
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.ETHEREUM)
  {
    bytes memory message = abi.encode('some message');

    vm.assume(caller != mailBox);
    hoax(caller);
    vm.expectRevert(bytes(Errors.CALLER_NOT_HL_MAILBOX));
    HyperLaneAdapter(address(hlAdapter)).handle(
      uint32(ChainIds.ETHEREUM),
      TypeCasts.addressToBytes32(originForwarder),
      message
    );
  }

  function testHandleWhenWrongSrcAddress(
    address crossChainController,
    address mailBox,
    address originForwarder,
    uint256 baseGasLimit,
    address srcAddress
  )
    public
    setHLAdapter(crossChainController, mailBox, originForwarder, baseGasLimit, ChainIds.ETHEREUM)
  {
    vm.assume(srcAddress != originForwarder);
    bytes memory message = abi.encode('some message');

    hoax(mailBox);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    HyperLaneAdapter(address(hlAdapter)).handle(
      uint32(ChainIds.ETHEREUM),
      TypeCasts.addressToBytes32(srcAddress),
      message
    );
  }

  function _testForwardMessage(
    address mailBox,
    address receiver,
    uint256 dstGasLimit,
    uint256 baseGasLimit,
    address caller
  ) internal {
    bytes memory message = abi.encode('test message');
    bytes32 messageId = keccak256(abi.encode(1));

    hoax(caller, 10 ether);
    vm.mockCall(
      mailBox,
      abi.encodeWithSelector(
        IMailbox.quoteDispatch.selector,
        uint32(ChainIds.POLYGON),
        TypeCasts.addressToBytes32(receiver),
        message,
        StandardHookMetadata.overrideGasLimit(dstGasLimit + baseGasLimit)
      ),
      abi.encode(10)
    );
    vm.mockCall(mailBox, abi.encodeWithSelector(IMailbox.dispatch.selector), abi.encode(messageId));

    (bool success, bytes memory returnData) = address(hlAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        receiver,
        dstGasLimit,
        ChainIds.POLYGON,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(mailBox, messageId));
  }
}
