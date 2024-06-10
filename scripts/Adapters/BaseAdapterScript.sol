// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

struct BaseAdapterArgs {
  address crossChainController;
  uint256 providerGasLimit;
  IBaseAdapter.TrustedRemotesConfig[] trustedRemotes;
  bool isTestnet;
}

struct RemoteCCC {
  uint256 chainId;
  address crossChainController;
}

abstract contract BaseAdapterScript is BaseScript {
  function REMOTE_CCC_BY_NETWORK() internal view virtual returns (RemoteCCC[] memory);

  function PROVIDER_GAS_LIMIT() internal view virtual returns (uint256) {
    return 0;
  }

  function SALT() internal view virtual returns (string memory) {
    return 'a.DI Adapter';
  }

  function isTestnet() internal view virtual returns (bool) {
    return false;
  }

  function _getAdapterByteCode(
    BaseAdapterArgs memory baseArgs
  ) internal view virtual returns (bytes memory);

  function _deployAdapter(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal returns (address) {
    bytes memory adapterCode = _getAdapterByteCode(
      BaseAdapterArgs({
        crossChainController: currentNetworkCCC,
        providerGasLimit: PROVIDER_GAS_LIMIT(),
        trustedRemotes: trustedRemotes,
        isTestnet: isTestnet()
      })
    );

    return Create2Utils.create2Deploy(keccak256(abi.encode(SALT())), adapterCode);
  }

  function _getTrustedRemotes() internal view returns (IBaseAdapter.TrustedRemotesConfig[] memory) {
    RemoteCCC[] memory remoteCrossChainControllers = REMOTE_CCC_BY_NETWORK();

    // generate trusted trustedRemotes
    IBaseAdapter.TrustedRemotesConfig[]
      memory trustedRemotes = new IBaseAdapter.TrustedRemotesConfig[](
        remoteCrossChainControllers.length
      );

    for (uint256 i = 0; i < remoteCrossChainControllers.length; i++) {
      trustedRemotes[i] = IBaseAdapter.TrustedRemotesConfig({
        originForwarder: remoteCrossChainControllers[i].crossChainController,
        originChainId: remoteCrossChainControllers[i].chainId
      });
    }
    return trustedRemotes;
  }
}
