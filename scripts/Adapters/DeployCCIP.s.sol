// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CCIPAdapter, ICCIPAdapter, IBaseAdapter} from '../../src/contracts/adapters/ccip/CCIPAdapter.sol';
import './BaseAdapterScript.sol';
import {CCIPAdapterTestnet} from '../contract_extensions/CCIPAdapter.sol';

contract DeployCCIPAdapter is BaseAdapterScript {
  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    if (isTestNet()) {
      addresses.ccipAdapter = address(
        new CCIPAdapterTestnet(
          addresses.crossChainController,
          CCIP_ROUTER(),
          trustedRemotes,
          LINK_TOKEN()
        )
      );
    } else {
      addresses.ccipAdapter = address(
        new CCIPAdapter(addresses.crossChainController, CCIP_ROUTER(), trustedRemotes, LINK_TOKEN())
      );
    }
  }
}

//{
//  ethereum: {
//    ccipRouter: 0xE561d5E02207fb5eB32cca20a699E0d8919a1476,
//    linkToken: 0x514910771AF9Ca656af840dff83E8264EcF986CA
//  },
//  avalanche: {
//    ccipRouter: 0x27F39D0af3303703750D4001fCc1844c6491563c,
//    linkToken: 0x5947BB275c521040051D82396192181b413227A3
//  },
//  polygon: {
//    ccipRouter: 0x3C3D92629A02a8D95D5CB9650fe49C3544f69B43,
//    linkToken: 0xb0897686c545045aFc77CF20eC7A532E3120E0F1
//  },
//  binance: {
//    ccipRouter: 0x536d7E53D0aDeB1F20E7c81fea45d02eC9dBD698,
//    linkToken: 0x404460C6A5EdE2D891e8297795264fDe62ADBB75
//  }
//}
