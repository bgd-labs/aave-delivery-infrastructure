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
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param lineaMessageService linea entry point address
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address lineaMessageService,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  )
    LineaAdapter(
      crossChainController,
      lineaMessageService,
      providerGasLimit,
      trustedRemotes,
      'Linea native  adapter'
    )
  {}

  /// @inheritdoc ILineaAdapter
  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.LINEA_SEPOLIA;
  }

  /// @inheritdoc ILineaAdapter
  function getOriginChainId() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
