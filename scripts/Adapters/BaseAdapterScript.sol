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

  function _computeAdapterAddress(address currentNetworkCCC) internal view returns (address) {
    bytes memory adapterCode = _getAdapterByteCode(currentNetworkCCC);
    bytes32 salt = keccak256(abi.encode(SALT()));

    return Create2Utils.computeCreate2Address(salt, adapterCode);
  }

  function _getAdapterByteCode(address currentNetworkCCC) internal view returns (bytes memory) {
    return
      _getAdapterByteCode(
        BaseAdapterArgs({
          crossChainController: currentNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: _getTrustedRemotes(),
          isTestnet: isTestnet()
        })
      );
  }

  function _getAdapterByteCode(
    BaseAdapterArgs memory baseArgs
  ) internal view virtual returns (bytes memory);

  function _deployAdapter(address currentNetworkCCC) internal returns (address) {
    require(currentNetworkCCC != address(0), 'CCC needs to be deployed');

    bytes memory adapterCode = _getAdapterByteCode(currentNetworkCCC);

    return _deployByteCode(adapterCode, SALT());
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
