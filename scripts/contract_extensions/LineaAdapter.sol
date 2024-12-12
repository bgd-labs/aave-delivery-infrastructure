// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {ILineaAdapter, LineaAdapter} from '../../src/contracts/adapters/linea/LineaAdapter.sol';

/**
 * @title LineaAdapterTestnet
 * @author BGD Labs
 */
contract LineaAdapterTestnet is LineaAdapter {
  /**
   * @param params object containing the necessary parameters to initialize the contract
   */
  constructor(ILineaAdapter.LineaParams memory params) LineaAdapter(params) {}

  /// @inheritdoc ILineaAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.LINEA_SEPOLIA;
  }

  /// @inheritdoc ILineaAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
