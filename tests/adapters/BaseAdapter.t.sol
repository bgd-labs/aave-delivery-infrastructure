// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';
import {Errors} from '../../src/contracts/libs/Errors.sol';

contract MockAdapter is BaseAdapter {
  constructor(
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Base adapter', trustedRemotes) {}

  function forwardMessage(
    address,
    uint256,
    uint256,
    bytes memory
  ) external pure returns (address, uint256) {
    return (address(0), 0);
  }

  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }
}

contract BaseAdapterTest is Test {
  function setUp() public {}

  function testContractCreationWhenAddress0() public {
    vm.expectRevert(bytes(Errors.INVALID_BASE_ADAPTER_CROSS_CHAIN_CONTROLLER));
    new MockAdapter(address(0), 0, new IBaseAdapter.TrustedRemotesConfig[](1));
  }
}
