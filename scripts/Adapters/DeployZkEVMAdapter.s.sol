// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';
import {ZkEVMAdapterGoerli, ZkEVMAdapterZkEVMGoerli} from '../contract_extensions/ZkEVMAdapterTestnets.sol';
import {IBaseAdapterScript} from './BaseAdapterStructs.sol';

contract BaseEthereumZKEVMAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address zkEVMBridge
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new ZkEVMAdapterGoerli{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            zkEVMBridge,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new ZkEVMAdapterEthereum{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            zkEVMBridge,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}

contract BaseZKEVMAdapter is IBaseAdapterScript {
  function _deployAdapter(
    IBaseAdapterScript.BaseAdapterArgs memory baseArgs,
    address zkEVMBridge
  ) internal returns (address) {
    if (baseArgs.isTestnet) {
      return
        address(
          new ZkEVMAdapterZkEVMGoerli{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            zkEVMBridge,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    } else {
      return
        address(
          new ZkEVMAdapterPolygonZkEVM{salt: baseArgs.adapterSalt}(
            baseArgs.crossChainController,
            zkEVMBridge,
            baseArgs.providerGasLimit,
            baseArgs.trustedRemotes
          )
        );
    }
  }
}
