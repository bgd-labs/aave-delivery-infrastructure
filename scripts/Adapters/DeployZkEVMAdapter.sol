// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ArbAdapter, IArbAdapter, IBaseAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import './BaseAdapterScript.sol';
import {ZkEVMAdapterEthereum} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterEthereum.sol';
import {ZkEVMAdapterPolygonZkEVM} from '../../src/contracts/adapters/zkEVM/ZkEVMAdapterPolygonZkEVM.sol';

library ZKEVMAdapterDeploymentHelper {
  struct ZKEVMAdapterArgs {
    BaseAdapterArgs baseArgs;
    address zkEVMBridge;
  }

  function getAdapterCode(
    ZKEVMAdapterArgs memory zkevmArgs,
    uint256 chainId
  ) internal pure returns (bytes memory) {
    bytes memory creationCode;
    // For now we dont have zk evm testnets as we only have goerli implemented which should no longer be suported
    if (chainId == ChainIds.ETHEREUM) {
      creationCode = type(ZkEVMAdapterEthereum).creationCode;
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      creationCode = type(ZkEVMAdapterPolygonZkEVM).creationCode;
    } else {
      revert('wrong chain id');
    }

    return
      abi.encodePacked(
        creationCode,
        abi.encode(
          zkevmArgs.baseArgs.crossChainController,
          zkevmArgs.zkEVMBridge,
          zkevmArgs.baseArgs.providerGasLimit,
          zkevmArgs.baseArgs.trustedRemotes
        )
      );
  }
}

contract BaseZKEVMAdapter is BaseAdapterScript {
  function ZK_EVM_BRIDGE() internal view virtual returns (address);

  function _getAdapterByteCode(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (bytes memory) {
    require(currentNetworkCCC != address(0), 'CCC needs to be deployed');
    require(ZK_EVM_BRIDGE() != address(0), 'Invalid zkevm bridge');

    ZKEVMAdapterDeploymentHelper.ZKEVMAdapterArgs
      memory constructorArgs = ZKEVMAdapterDeploymentHelper.ZKEVMAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: currentNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        zkEVMBridge: ZK_EVM_BRIDGE()
      });

    return ZKEVMAdapterDeploymentHelper.getAdapterCode(constructorArgs, TRANSACTION_NETWORK());
  }
}
