// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import {ChainIds} from 'aave-helpers/ChainIds.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';
import {PolygonAdapterEthereum} from '../../src/contracts/adapters/polygon/PolygonAdapterEthereum.sol';
import {PolygonAdapterPolygon} from '../../src/contracts/adapters/polygon/PolygonAdapterPolygon.sol';
import {IFxTunnel} from '../../src/contracts/adapters/polygon/tunnel/interfaces/IFxTunnel.sol';

contract PolygonAdapterTest is Test {
  address public constant ORIGIN_FORWARDER = address(123);
  address public constant CROSS_CHAIN_CONTROLLER = address(1234);
  address public constant FX_TUNNEL_ETHEREUM = address(12345);
  address public constant RECEIVER_CROSS_CHAIN_CONTROLLER = address(1234567);
  address public constant FX_TUNNEL_POLYGON = address(12345678);
  uint256 public constant ORIGIN_CHAIN_ID = ChainIds.ETHEREUM;
  uint256 public constant DESTINATION_CHAIN_ID = ChainIds.POLYGON;
  address public constant ADDRESS_WITH_ETH = address(12301234);
  uint256 public constant BASE_GAS_LIMIT = 10_000;

  PolygonAdapterEthereum public polygonAdapterEthereum;
  PolygonAdapterPolygon public polygonAdapterPolygon;

  IBaseAdapter.TrustedRemotesConfig internal originConfigPolygon =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: CROSS_CHAIN_CONTROLLER,
      originChainId: ORIGIN_CHAIN_ID
    });

  IBaseAdapter.TrustedRemotesConfig internal originConfigEthereum =
    IBaseAdapter.TrustedRemotesConfig({
      originForwarder: CROSS_CHAIN_CONTROLLER,
      originChainId: DESTINATION_CHAIN_ID
    });

  function setUp() public {
    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigsEthereum = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigsEthereum[0] = originConfigEthereum;

    polygonAdapterEthereum = new PolygonAdapterEthereum(
      CROSS_CHAIN_CONTROLLER,
      FX_TUNNEL_ETHEREUM,
      BASE_GAS_LIMIT,
      originConfigsEthereum
    );

    IBaseAdapter.TrustedRemotesConfig[]
      memory originConfigsPolygon = new IBaseAdapter.TrustedRemotesConfig[](1);
    originConfigsPolygon[0] = originConfigPolygon;

    polygonAdapterPolygon = new PolygonAdapterPolygon(
      CROSS_CHAIN_CONTROLLER,
      FX_TUNNEL_POLYGON,
      BASE_GAS_LIMIT,
      originConfigsPolygon
    );
  }

  function testInitialize() public {
    assertEq(
      keccak256(abi.encode(polygonAdapterEthereum.adapterName())),
      keccak256(abi.encode('Polygon native adapter'))
    );
    assertEq(
      keccak256(abi.encode(polygonAdapterPolygon.adapterName())),
      keccak256(abi.encode('Polygon native adapter'))
    );
    assertEq(
      polygonAdapterEthereum.getTrustedRemoteByChainId(DESTINATION_CHAIN_ID),
      CROSS_CHAIN_CONTROLLER
    );
    assertEq(
      polygonAdapterPolygon.getTrustedRemoteByChainId(ORIGIN_CHAIN_ID),
      CROSS_CHAIN_CONTROLLER
    );
  }

  function testGetInfraChainFromBridgeChain() public {
    assertEq(polygonAdapterEthereum.nativeToInfraChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
    assertEq(polygonAdapterPolygon.nativeToInfraChainId(ChainIds.POLYGON), ChainIds.POLYGON);
  }

  function testGetBridgeChainFromInfraChain() public {
    assertEq(polygonAdapterEthereum.infraToNativeChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
    assertEq(polygonAdapterPolygon.infraToNativeChainId(ChainIds.ETHEREUM), ChainIds.ETHEREUM);
  }

  function testForwardMessageToPolygon() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      FX_TUNNEL_ETHEREUM,
      abi.encodeWithSelector(
        IFxTunnel.sendMessage.selector,
        address(polygonAdapterPolygon),
        message
      ),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(polygonAdapterEthereum).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        address(polygonAdapterPolygon),
        dstGasLimit,
        ChainIds.POLYGON,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(FX_TUNNEL_ETHEREUM, 0));
  }

  function testForwardMessageToEthereum() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);
    vm.mockCall(
      FX_TUNNEL_POLYGON,
      abi.encodeWithSelector(
        IFxTunnel.sendMessage.selector,
        address(polygonAdapterEthereum),
        message
      ),
      abi.encode()
    );
    (bool success, bytes memory returnData) = address(polygonAdapterPolygon).delegatecall(
      abi.encodeWithSelector(
        IBaseAdapter.forwardMessage.selector,
        address(polygonAdapterEthereum),
        dstGasLimit,
        ChainIds.ETHEREUM,
        message
      )
    );
    vm.clearMockedCalls();

    assertEq(success, true);
    assertEq(returnData, abi.encode(FX_TUNNEL_POLYGON, 0));
  }

  function testForwardMessageWhenChainNotSupported() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint32 dstGasLimit = 600000;

    hoax(ADDRESS_WITH_ETH, 10 ether);

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    polygonAdapterEthereum.forwardMessage(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      dstGasLimit,
      ChainIds.ETHEREUM,
      message
    );

    vm.expectRevert(bytes(Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED));
    polygonAdapterPolygon.forwardMessage(
      RECEIVER_CROSS_CHAIN_CONTROLLER,
      dstGasLimit,
      ChainIds.POLYGON,
      message
    );
  }

  function testForwardMessageWhenWrongReceiver() public {
    uint40 payloadId = uint40(0);
    bytes memory message = abi.encode(payloadId, CROSS_CHAIN_CONTROLLER);
    uint256 dstGasLimit = 600000;

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    polygonAdapterEthereum.forwardMessage(address(0), dstGasLimit, ChainIds.POLYGON, message);

    vm.expectRevert(bytes(Errors.RECEIVER_NOT_SET));
    polygonAdapterPolygon.forwardMessage(address(0), dstGasLimit, ChainIds.ETHEREUM, message);
  }

  function testProcessMessageFromRoot() public {
    bytes memory message = abi.encode('some message');
    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      CROSS_CHAIN_CONTROLLER,
      0,
      abi.encodeWithSelector(
        ICrossChainReceiver.receiveCrossChainMessage.selector,
        message,
        ORIGIN_CHAIN_ID
      )
    );
    hoax(FX_TUNNEL_POLYGON);
    polygonAdapterPolygon.processMessage(CROSS_CHAIN_CONTROLLER, message);
  }

  function testProcessMessageFromChild() public {
    bytes memory message = abi.encode('some message');
    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(ICrossChainReceiver.receiveCrossChainMessage.selector),
      abi.encode()
    );
    vm.expectCall(
      CROSS_CHAIN_CONTROLLER,
      0,
      abi.encodeWithSelector(
        ICrossChainReceiver.receiveCrossChainMessage.selector,
        message,
        DESTINATION_CHAIN_ID
      )
    );
    hoax(FX_TUNNEL_ETHEREUM);
    polygonAdapterEthereum.processMessage(CROSS_CHAIN_CONTROLLER, message);
  }

  function testProcessMessageWhenCallerNotFxTunnel() public {
    bytes memory message = abi.encode('some message');
    vm.expectRevert(bytes(Errors.CALLER_NOT_FX_TUNNEL));
    polygonAdapterPolygon.processMessage(CROSS_CHAIN_CONTROLLER, message);

    vm.expectRevert(bytes(Errors.CALLER_NOT_FX_TUNNEL));
    polygonAdapterEthereum.processMessage(CROSS_CHAIN_CONTROLLER, message);
  }

  function testReceiveWhenRemote_CallerNotTrusted() public {
    bytes memory message = abi.encode('some message');

    hoax(FX_TUNNEL_ETHEREUM);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    polygonAdapterEthereum.processMessage(address(0x4546b), message);

    hoax(FX_TUNNEL_POLYGON);
    vm.expectRevert(bytes(Errors.REMOTE_NOT_TRUSTED));
    polygonAdapterPolygon.processMessage(address(0x4546b), message);
  }
}
