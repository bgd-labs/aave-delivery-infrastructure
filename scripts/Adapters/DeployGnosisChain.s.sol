// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GnosisChainAdapter, IBaseAdapter} from '../../src/contracts/adapters/gnosisChain/GnosisChainAdapter.sol';

abstract contract BaseGnosisChainAdapter {
  function _deployAdapter(
    address crossChainController,
    address gnosisAMBBridge,
    uint256 providerGasLimit,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes,
    bytes32 adapterSalt
  ) internal override {
    return
      address(
        new GnosisChainAdapter{salt: adapterSalt}(
          crossChainController,
          gnosisAMBBridge,
          providerGasLimit,
          trustedRemotes
        )
      );
  }
}
