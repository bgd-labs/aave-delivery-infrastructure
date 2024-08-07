// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {PolygonAdapterBase} from '../../src/contracts/adapters/polygon/PolygonAdapterBase.sol';
import {IPolygonAdapter} from '../../src/contracts/adapters/polygon/IPolygonAdapter.sol';

contract PolygonAdapterMumbai is PolygonAdapterBase {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param fxTunnel polygon bridge address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address fxTunnel,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) PolygonAdapterBase(crossChainController, fxTunnel, providerGasLimit, trustedRemotes) {}

  /// @inheritdoc IPolygonAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  /// @inheritdoc IPolygonAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract PolygonAdapterGoerli is PolygonAdapterBase {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param fxTunnel polygon bridge address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address fxTunnel,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) PolygonAdapterBase(crossChainController, fxTunnel, providerGasLimit, trustedRemotes) {}

  /// @inheritdoc IPolygonAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.POLYGON_AMOY;
  }

  /// @inheritdoc IPolygonAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_AMOY;
  }
}
