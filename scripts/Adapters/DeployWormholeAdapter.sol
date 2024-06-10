// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {WormholeAdapter, IWormholeAdapter, IBaseAdapter} from '../../src/contracts/adapters/wormhole/WormholeAdapter.sol';
import './BaseAdapterScript.sol';
import {WormholeAdapterTestnet} from '../contract_extensions/WormholeAdapter.sol';

library WormholeAdapterDeploymentHelper {
  struct WormholeAdapterArgs {
    BaseAdapterArgs baseArgs;
    address wormholeRelayer;
    address destinationCCC;
  }

  function getAdapterCode(
    WormholeAdapterArgs memory wormholeArgs
  ) internal pure returns (bytes memory) {
    bytes memory creationCode = wormholeArgs.baseArgs.isTestnet
      ? type(WormholeAdapterTestnet).creationCode
      : type(WormholeAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          wormholeArgs.baseArgs.crossChainController,
          wormholeArgs.wormholeRelayer,
          wormholeArgs.destinationCCC,
          wormholeArgs.baseArgs.providerGasLimit,
          wormholeArgs.baseArgs.trustedRemotes
        )
      );
  }
}

abstract contract BaseWormholeAdapter is BaseAdapterScript {
  function WORMHOLE_RELAYER() internal view virtual returns (address);

  /// @dev for now we will need to deploy one adapter for every path (one remote network) because of the refunding on
  /// destination ccc
  function DESTINATION_CCC() internal view virtual returns (address);

  function _getAdapterByteCode(
    BaseAdapterArgs memory baseArgs
  ) internal view override returns (bytes memory) {
    require(baseArgs.crossChainController != address(0), 'CCC needs to be deployed');
    require(DESTINATION_CCC() != address(0), 'Invalid Destination CCC');
    require(WORMHOLE_RELAYER() != address(0), 'Wormhole relayer can not be 0');

    return
      WormholeAdapterDeploymentHelper.getAdapterCode(
        WormholeAdapterDeploymentHelper.WormholeAdapterArgs({
          baseArgs: baseArgs,
          wormholeRelayer: WORMHOLE_RELAYER(),
          destinationCCC: DESTINATION_CCC()
        })
      );
  }
}
