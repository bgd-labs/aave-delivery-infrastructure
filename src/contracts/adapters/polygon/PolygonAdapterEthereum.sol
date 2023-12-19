// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PolygonAdapterBase} from './PolygonAdapterBase.sol';
import {ChainIds} from '../../libs/ChainIds.sol';

contract PolygonAdapterEthereum is PolygonAdapterBase {
  constructor(
    address crossChainController,
    address fxTunnel,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) PolygonAdapterBase(crossChainController, fxTunnel, providerGasLimit, trustedRemotes) {}

  // Overrides to use the Polygon chain id, which is Ethereum's origin
  function getOriginChainId() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  // Overrides to use the Polygon chain id, which is Ethereum's destination
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == ChainIds.POLYGON;
  }
}
