// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WormholeAdapter, IBaseAdapter, IWormholeRelayer} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import {IWormholeAdapter} from '../../src/contracts/adapters/wormhole/IWormholeAdapter.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';

contract WormholeAdapterTest is BaseAdapterTest {
  WormholeAdapter internal wormholeAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setHLAdapter(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(baseGasLimit < 1 ether);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(wormholeRelayer);
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    wormholeAdapter = new WormholeAdapter(
      crossChainController,
      wormholeRelayer,
      refundAddress,
      baseGasLimit,
      originConfigs
    );
    _;
  }

  function setUp() public {}

  function testWrongWormholeRelayer(
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
    vm.expectRevert(bytes(Errors.WORMHOLE_RELAYER_CANT_BE_ADDRESS_0));
    new WormholeAdapter(
      crossChainController,
      address(0),
      refundAddress,
      baseGasLimit,
      originConfigs
    );
  }

  function testInitialize(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      originChainId
    )
  {
    assertEq(wormholeAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  function testGetInfraChainFromBridgeChain(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    assertEq(wormholeAdapter.nativeToInfraChainId(uint16(2)), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    assertEq(wormholeAdapter.infraToNativeChainId(ChainIds.ETHEREUM), uint16(2));
  }

  function testForwardMessage(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    address caller,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(caller != address(0));
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    _testForwardMessage(wormholeRelayer, receiver, dstGasLimit, caller);
  }

  function testForwardMessageWhenNoValue(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));
    _testForwardMessageWhenNoValue(wormholeRelayer, receiver, dstGasLimit);
  }

  function _testForwardMessageWhenNoValue(
    address wormholeRelayer,
    address receiver,
    uint256 dstGasLimit
  ) internal {
    bytes memory message = abi.encode('test message');

    vm.mockCall(
      wormholeRelayer,
      abi.encodeWithSelector(IWormholeRelayer.quoteEVMDeliveryPrice.selector),
      abi.encode(10, 0)
    );
    vm.mockCall(
      wormholeRelayer,
      10,
      abi.encodeWithSelector(IWormholeRelayer.sendPayloadToEvm.selector),
      abi.encode(uint64(1))
    );
    vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));
    (bool success, ) = address(wormholeAdapter).delegatecall(
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

  function testForwardMessageWhenChainNotSupported(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver,
    bytes memory message
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    wormholeAdapter.forwardMessage(receiver, dstGasLimit, 11, message);
  }

  function testForwardMessageWhenWrongReceiver(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    bytes memory message
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    wormholeAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.POLYGON, message);
  }

  function testReceive(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    bytes memory message
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    hoax(wormholeRelayer);
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
    wormholeAdapter.receiveWormholeMessages(
      message,
      new bytes[](0),
      bytes32(uint256(uint160(originForwarder))),
      uint16(2),
      bytes32(0)
    );
  }

  function testReceiveWhenCallerNotRouter(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    address caller
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(caller != wormholeRelayer);
    hoax(caller);
    vm.expectRevert(bytes(Errors.CALLER_NOT_WORMHOLE_RELAYER));
    wormholeAdapter.receiveWormholeMessages(
      abi.encode('test message'),
      new bytes[](0),
      bytes32(uint256(uint160(originForwarder))),
      uint16(2),
      bytes32(0)
    );
  }

  function testReceiveWhenRemoteNotTrusted(
    address crossChainController,
    address wormholeRelayer,
    address originForwarder,
    address refundAddress,
    uint256 baseGasLimit,
    uint16 sourceChainId,
    address remote
  )
    public
    setHLAdapter(
      crossChainController,
      wormholeRelayer,
      originForwarder,
      refundAddress,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(remote != originForwarder);

    hoax(wormholeRelayer);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    wormholeAdapter.receiveWormholeMessages(
      abi.encode('test message'),
      new bytes[](0),
      bytes32(uint256(uint160(remote))),
      sourceChainId,
      bytes32(0)
    );
  }

  function _testForwardMessage(
    address wormholeRelayer,
    address receiver,
    uint256 dstGasLimit,
    address caller
  ) internal {
    bytes memory message = abi.encode('test message');

    hoax(caller, 10 ether);

    vm.mockCall(
      wormholeRelayer,
      abi.encodeWithSelector(IWormholeRelayer.quoteEVMDeliveryPrice.selector),
      abi.encode(10, 0)
    );
    vm.mockCall(
      wormholeRelayer,
      10,
      abi.encodeWithSelector(IWormholeRelayer.sendPayloadToEvm.selector),
      abi.encode(uint64(1))
    );
    (bool success, bytes memory returnData) = address(wormholeAdapter).delegatecall(
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
    assertEq(returnData, abi.encode(wormholeRelayer, uint64(1)));
  }
}
