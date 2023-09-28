// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console2.sol';
import 'forge-std/Script.sol';

import {FxTunnelPolygon} from '../src/contracts/adapters/polygon/tunnel/FxTunnelPolygon.sol';
import {FxTunnelEthereum} from '../src/contracts/adapters/polygon/tunnel/FxTunnelEthereum.sol';

address constant ETHEREUM_CHECKPOINT_MANAGER = 0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287;
address constant ETHEREUM_FX_ROOT = 0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2;
address constant POLYGON_FX_CHILD = 0x8397259c983751DAf40400790063935a11afa28a;
address constant GOERLI_CHECKPOINT_MANAGER = 0x2890bA17EfE978480615e330ecB65333b880928e;
address constant GOERLI_FX_ROOT = 0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA;
address constant MUMBAI_FX_CHILD = 0xCf73231F28B7331BBe3124B907840A94851f9f11;

contract Polygon is Script {
  address FX_TUNNEL_ETHEREUM = 0xF30FA9e36FdDd4982B722432FD39914e9ab2b033;

  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    require(FX_TUNNEL_ETHEREUM != address(0), 'Zero tunnel');
    FxTunnelPolygon tunnel = new FxTunnelPolygon(POLYGON_FX_CHILD, FX_TUNNEL_ETHEREUM);
    console2.log('FxTunnelPolygon: %s', address(tunnel));
  }
}

contract Ethereum is Script {
  address FX_TUNNEL_POLYGON = 0xF30FA9e36FdDd4982B722432FD39914e9ab2b033;

  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    require(FX_TUNNEL_POLYGON != address(0), 'Zero tunnel');
    FxTunnelEthereum tunnel = new FxTunnelEthereum(
      ETHEREUM_CHECKPOINT_MANAGER,
      ETHEREUM_FX_ROOT,
      FX_TUNNEL_POLYGON
    );
    console2.log('FxTunnelEthereum: %s', address(tunnel));
  }
}

contract Polygon_testnet is Script {
  address FX_TUNNEL_ETHEREUM = address(0);

  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    require(FX_TUNNEL_ETHEREUM != address(0), 'Zero tunnel');
    FxTunnelPolygon tunnel = new FxTunnelPolygon(MUMBAI_FX_CHILD, FX_TUNNEL_ETHEREUM);
    console2.log('FxTunnelPolygon: %s', address(tunnel));
  }
}

contract Ethereum_testnet is Script {
  address FX_TUNNEL_POLYGON = address(0);

  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    require(FX_TUNNEL_POLYGON != address(0), 'Zero tunnel');
    FxTunnelEthereum tunnel = new FxTunnelEthereum(
      GOERLI_CHECKPOINT_MANAGER,
      GOERLI_FX_ROOT,
      FX_TUNNEL_POLYGON
    );
    console2.log('FxTunnelEthereum: %s', address(tunnel));
  }
}

contract DeployMockReceiver is Script {
  function run() external {
    vm.broadcast(vm.envUint('PRIVATE_KEY'));
    MockReceiver receiver = new MockReceiver();
    console2.log('MockReceiver: %s', address(receiver));
  }
}

contract MockReceiver {
  event StateUpdate(address indexed originSender, uint256 indexed newState);
  event MessageReceived(string message);
  uint256 public state;

  function processMessage(address originSender, bytes memory decodedMessage) external {
    emit StateUpdate(originSender, ++state);
    emit MessageReceived(string(decodedMessage));
  }
}
