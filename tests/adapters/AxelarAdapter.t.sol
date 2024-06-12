// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {BaseAdapterTest} from './BaseAdapterTest.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {Strings} from 'openzeppelin-contracts/contracts/utils/Strings.sol';
import {IAxelarAdapter, IBaseAdapter, AxelarAdapter, IAxelarGateway, IAxelarGasService} from '../../src/contracts/adapters/axelar/AxelarAdapter.sol';

contract AxelarAdapterTest is BaseAdapterTest {
  using Strings for string;
  AxelarAdapter internal axelarAdapter;

  event SetTrustedRemote(uint256 indexed originChainId, address indexed originForwarder);

  modifier setAxelarAdapter(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    uint256 originChainId
  ) {
    vm.assume(baseGasLimit < 1 ether);
    _assumeSafeAddress(crossChainController);
    _assumeSafeAddress(axelarGateway);
    _assumeSafeAddress(axelarGasService);
    _assumeSafeAddress(originForwarder);
    vm.assume(originForwarder != address(0));
    vm.assume(originChainId > 0);

    IBaseAdapter.TrustedRemotesConfig memory originConfig = IBaseAdapter.TrustedRemotesConfig({
      originForwarder: originForwarder,
      originChainId: originChainId
    });
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigs = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigs[0] = originConfig;

    axelarAdapter = new AxelarAdapter(
      IBaseAdapter.BaseAdapterArgs({
        crossChainController: crossChainController,
        providerGasLimit: baseGasLimit,
        trustedRemotes: originConfigs
      }),
      axelarGateway,
      axelarGasService
    );
    _;
  }

  function setUp() public {}

  function testWrongAxelarGateway(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
    address axelarGasService,
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

    IBaseAdapter.BaseAdapterArgs memory baseArgs = IBaseAdapter.BaseAdapterArgs({
      crossChainController: crossChainController,
      providerGasLimit: baseGasLimit,
      trustedRemotes: originConfigs
    });

    vm.expectRevert(bytes(Errors.INVALID_AXELAR_GATEWAY));
    new AxelarAdapter(baseArgs, address(0), axelarGasService);
  }

  function testWrongAxelarGasService(
    address crossChainController,
    uint256 baseGasLimit,
    address originForwarder,
    address axelarGateway,
    uint256 originChainId
  ) public {
    vm.assume(axelarGateway != address(0));
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

    IBaseAdapter.BaseAdapterArgs memory baseArgs = IBaseAdapter.BaseAdapterArgs({
      crossChainController: crossChainController,
      providerGasLimit: baseGasLimit,
      trustedRemotes: originConfigs
    });

    vm.expectRevert(bytes(Errors.INVALID_AXELAR_GAS_SERVICE));
    new AxelarAdapter(baseArgs, axelarGateway, address(0));
  }

  function testInitialize(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    uint256 originChainId
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      originChainId
    )
  {
    assertEq(axelarAdapter.getTrustedRemoteByChainId(originChainId), originForwarder);
  }

  function testGetInfraChainFromBridgeChain(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    assertEq(axelarAdapter.axelarNativeToInfraChainId('Ethereum'), ChainIds.ETHEREUM);
  }

  function testGetBridgeChainFromInfraChain(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    assertEq(axelarAdapter.axelarInfraToNativeChainId(ChainIds.ETHEREUM).equal('Ethereum'), true);
  }

  function testForwardMessage(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    address caller,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(caller != address(0));
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    _testForwardMessage(receiver, dstGasLimit, caller);
  }

  function testForwardMessageWhenNoValue(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));
    _testForwardMessageWhenNoValue(receiver, dstGasLimit);
  }

  function testForwardMessageWhenChainNotSupported(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    address receiver,
    bytes memory message
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);
    vm.assume(receiver != address(0));

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    axelarAdapter.forwardMessage(receiver, dstGasLimit, 11, message);
  }

  function testForwardMessageWhenWrongReceiver(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    uint256 dstGasLimit,
    bytes memory message
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(dstGasLimit > 200000 && dstGasLimit < 1 ether);

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    axelarAdapter.forwardMessage(address(0), dstGasLimit, ChainIds.POLYGON, message);
  }

  function testReceive(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    bytes memory payload
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.mockCall(
      address(axelarAdapter.AXELAR_GATEWAY()),
      abi.encodeWithSelector(IAxelarGateway.validateContractCall.selector),
      abi.encode(true)
    );
    vm.mockCall(
      crossChainController,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      crossChainController,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector, payload, 1)
    );
    axelarAdapter.execute(bytes32(0), 'Ethereum', Strings.toHexString(originForwarder), payload);
  }

  function testReceiveWhenContractCallNotConfirmed(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    bytes memory payload
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.mockCall(
      address(axelarAdapter.AXELAR_GATEWAY()),
      abi.encodeWithSelector(IAxelarGateway.validateContractCall.selector),
      abi.encode(false)
    );
    vm.expectRevert(bytes(Errors.INVALID_AXELAR_GATEWAY_CONTRACT_CALL));

    axelarAdapter.execute(bytes32(0), 'Ethereum', Strings.toHexString(originForwarder), payload);
  }

  function testReceiveWhenRemoteNotTrusted(
    address crossChainController,
    address axelarGateway,
    address originForwarder,
    address axelarGasService,
    uint256 baseGasLimit,
    bytes memory payload,
    address remote
  )
    public
    setAxelarAdapter(
      crossChainController,
      axelarGateway,
      originForwarder,
      axelarGasService,
      baseGasLimit,
      ChainIds.ETHEREUM
    )
  {
    vm.assume(remote != originForwarder);

    vm.mockCall(
      address(axelarAdapter.AXELAR_GATEWAY()),
      abi.encodeWithSelector(IAxelarGateway.validateContractCall.selector),
      abi.encode(true)
    );

    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));

    axelarAdapter.execute(bytes32(0), 'Ethereum', Strings.toHexString(remote), payload);
  }

  function _testForwardMessageWhenNoValue(address receiver, uint256 dstGasLimit) internal {
    bytes memory message = abi.encode('test message');

    vm.mockCall(
      address(axelarAdapter.AXELAR_GAS_SERVICE()),
      abi.encodeWithSelector(IAxelarGasService.estimateGasFee.selector),
      abi.encode(10)
    );

    vm.expectRevert(bytes(Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES));
    (bool success, ) = address(axelarAdapter).delegatecall(
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

  function _testForwardMessage(address receiver, uint256 dstGasLimit, address caller) internal {
    bytes memory message = abi.encode('test message');

    hoax(caller, 10 ether);

    vm.mockCall(
      address(axelarAdapter.AXELAR_GAS_SERVICE()),
      abi.encodeWithSelector(IAxelarGasService.estimateGasFee.selector),
      abi.encode(10)
    );
    vm.mockCall(
      address(axelarAdapter.AXELAR_GAS_SERVICE()),
      10,
      abi.encodeWithSelector(IAxelarGasService.payGas.selector),
      abi.encode()
    );
    vm.mockCall(
      address(axelarAdapter.AXELAR_GATEWAY()),
      abi.encodeWithSelector(IAxelarGateway.callContract.selector),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(axelarAdapter).delegatecall(
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
    assertEq(returnData, abi.encode(address(axelarAdapter.AXELAR_GATEWAY()), 0));
  }
}
