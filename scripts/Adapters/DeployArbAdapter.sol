// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import {ArbitrumAdapterTestnet} from '../contract_extensions/ArbitrumAdapter.sol';
import './BaseAdapterStructs.sol';

library ArbAdapterDeploymentHelper {
  struct ArbAdapterArgs {
    BaseAdapterStructs.BaseAdapterArgs baseArgs;
    address inbox;
    address destinationCCC;
  }

  function getAdapterCode(ArbAdapterArgs memory arbArgs) internal pure returns (bytes memory) {
    if (arbArgs.baseArgs.isTestnet) {
      return
        abi.encodePacked(
          type(ArbitrumAdapterTestnet).creationCode,
          abi.encode(
            arbArgs.baseArgs.crossChainController,
            arbArgs.inbox,
            arbArgs.destinationCCC,
            arbArgs.baseArgs.providerGasLimit,
            arbArgs.baseArgs.trustedRemotes
          )
        );
    } else {
      return
        abi.encodePacked(
          type(ArbAdapter).creationCode,
          abi.encode(
            arbArgs.baseArgs.crossChainController,
            arbArgs.inbox,
            arbArgs.destinationCCC,
            arbArgs.baseArgs.providerGasLimit,
            arbArgs.baseArgs.trustedRemotes
          )
        );
    }
  }
}
