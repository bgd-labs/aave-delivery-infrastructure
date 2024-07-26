// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.8;

import {TestNetChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {GnosisChainAdapter} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';
import {BaseAdapter, IBaseAdapter} from '../../src/contracts/adapters/BaseAdapter.sol';

/**
 * @title GnosisChainAdapterTestnet
 * @author BGD Labs
 */
contract GnosisChainAdapterTestnet is GnosisChainAdapter {
  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param arbitraryMessageBridge The Gnosis AMB contract
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address arbitraryMessageBridge,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  )
    GnosisChainAdapter(
      crossChainController,
      arbitraryMessageBridge,
      providerGasLimit,
      trustedRemotes
    )
  {}

  function isDestinationChainIdSupported(uint256 chainId) public pure override returns (bool) {
    return chainId == TestNetChainIds.GNOSIS_CHIADO;
  }
}
