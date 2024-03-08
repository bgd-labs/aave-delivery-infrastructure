// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../../src/contracts/adapters/IBaseAdapter.sol';

import '../BaseScript.sol';

abstract contract BaseAdapterScript is BaseScript {
  function REMOTE_NETWORKS() public view virtual returns (uint256[] memory);

  function GET_BASE_GAS_LIMIT() public view virtual returns (uint256) {
    return 0;
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal virtual;

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    uint256[] memory remoteNetworks = REMOTE_NETWORKS();

    // generate trusted trustedRemotes
    IBaseAdapter.TrustedRemotesConfig[]
      memory trustedRemotes = new IBaseAdapter.TrustedRemotesConfig[](remoteNetworks.length);

    for (uint256 i = 0; i < remoteNetworks.length; i++) {
      DeployerHelpers.Addresses memory remoteAddresses = _getAddresses(remoteNetworks[i]);

      trustedRemotes[i] = IBaseAdapter.TrustedRemotesConfig({
        originForwarder: remoteAddresses.crossChainController,
        originChainId: remoteAddresses.chainId
      });
    }

    _deployAdapter(addresses, trustedRemotes);
  }
}
