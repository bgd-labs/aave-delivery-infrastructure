// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LineaAdapter, IBaseAdapter, ILineaAdapter, IMessageService} from '../../src/contracts/adapters/linea/LineaAdapter.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';

contract LineaAdapterTest is BaseAdapterTest {
  LineaAdapter internal lineaAdapter;
  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setLineaAdapter(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(crossChainController != tx.origin); // zkVM doesn't support mocking tx.origin
    vm.assume(baseGasLimit < 1 ether);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(lineaMessageService);
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    lineaAdapter = new LineaAdapter(
      crossChainController,
      lineaMessageService,
      baseGasLimit,
      originConfigs
    );
    _;
  }

  struct Params {
    address lineaMessageService;
    address receiver;
    uint256 dstGasLimit;
    address caller;
  }

  function setUp() public {}

  function testWrongLineaMessageSender(
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
    vm.expectRevert(bytes(Errors.LINEA_MESSAGE_SERVICE_CANT_BE_ADDRESS_0));
    new LineaAdapter(crossChainController, address(0), baseGasLimit, originConfigs);
  }

  function testInitialize(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setLineaAdapter(
      crossChainController,
      lineaMessageService,
      originForwarder,
      baseGasLimit,
      originChainId
    )
  {
    assertEq(lineaAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  function testForwardMessage(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setLineaAdapter(
      crossChainController,
      lineaMessageService,
      originForwarder,
      baseGasLimit,
      originChainId
    )
  {
    _testForwardMessage(
      Params({
        lineaMessageService: lineaMessageService,
        receiver: address(135961),
        dstGasLimit: 12,
        caller: address(12354)
      })
    );
  }

  function testForwardMessageWhenChainNotSupported(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId,
    uint256 dstGasLimit,
    address receiver,
    bytes memory message
  )
    public
    setLineaAdapter(
      crossChainController,
      lineaMessageService,
      originForwarder,
      baseGasLimit,
      originChainId
    )
  {
    vm.assume(receiver != address(0));

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    lineaAdapter.forwardMessage(receiver, dstGasLimit, 11, message);
  }

  function testForwardMessageWhenWrongReceiver(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    uint256 originChainId,
    uint256 dstGasLimit,
    bytes memory message
  )
    public
    setLineaAdapter(
      crossChainController,
      lineaMessageService,
      originForwarder,
      baseGasLimit,
      originChainId
    )
  {
    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    lineaAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.LINEA, message);
  }

  function testReceive(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    bytes memory message
  )
    public
    setLineaAdapter(crossChainController, lineaMessageService, originForwarder, baseGasLimit, 1)
  {
    hoax(lineaMessageService);

    vm.mockCall(
      lineaMessageService,
      abi.encodeWithSelector(IMessageService.sender.selector),
      abi.encode(originForwarder)
    );
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
    lineaAdapter.receiveMessage(message);
  }

  function testReceiveWhenRemoteNotTrusted(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    bytes memory message,
    address remote
  )
    public
    setLineaAdapter(crossChainController, lineaMessageService, originForwarder, baseGasLimit, 1)
  {
    vm.assume(remote != originForwarder);
    hoax(lineaMessageService);

    vm.mockCall(
      lineaMessageService,
      abi.encodeWithSelector(IMessageService.sender.selector),
      abi.encode(remote)
    );
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    lineaAdapter.receiveMessage(message);
  }

  function testReceiveWhenIncorrectOriginChainId(
    address crossChainController,
    address lineaMessageService,
    address originForwarder,
    uint256 baseGasLimit,
    bytes memory message,
    uint256 originChainId
  )
    public
    setLineaAdapter(
      crossChainController,
      lineaMessageService,
      originForwarder,
      baseGasLimit,
      originChainId
    )
  {
    vm.assume(originChainId != 1);
    hoax(lineaMessageService);

    vm.mockCall(
      lineaMessageService,
      abi.encodeWithSelector(IMessageService.sender.selector),
      abi.encode(originForwarder)
    );
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    lineaAdapter.receiveMessage(message);
  }

  function _testForwardMessage(Params memory params) internal {
    bytes memory message = abi.encode('test message');

    hoax(params.caller, 10 ether);

    vm.mockCall(
      params.lineaMessageService,
      abi.encodeWithSelector(IMessageService.sendMessage.selector),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(lineaAdapter).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        params.receiver,
        params.dstGasLimit,
        ChainIds.LINEA,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(params.lineaMessageService, 0));
  }
}
