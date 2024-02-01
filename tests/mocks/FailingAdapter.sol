// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';

contract FailingAdapter is BaseAdapter {
  constructor(
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(address(1), 0, 'failing adapter', trustedRemotes) {}

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address,
    uint256,
    uint256,
    bytes memory
  ) external pure returns (address, uint256) {
    revert('error message');
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256) public pure override returns (uint256) {
    revert('error message');
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256) public pure override returns (uint256) {
    revert('error message');
  }
}
