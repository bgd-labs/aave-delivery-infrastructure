// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PolygonAdapterBase} from './PolygonAdapterBase.sol';
import {ChainIds} from '../../libs/ChainIds.sol';

contract PolygonAdapterPolygon is PolygonAdapterBase {
  constructor(
    address crossChainController,
    address fxTunnel,
    uint256 baseGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) PolygonAdapterBase(crossChainController, fxTunnel, baseGasLimit, trustedRemotes) {}

  // Overrides to use Ethereum chain id, which is Polygon's origin
  function getOriginChainId() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  // Overrides to use Ethereum chain id, which is Polygon's destination
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == ChainIds.ETHEREUM;
  }
}
