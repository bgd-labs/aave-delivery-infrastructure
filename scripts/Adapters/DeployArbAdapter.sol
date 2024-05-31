// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {ArbAdapter, IArbAdapter} from '../../src/contracts/adapters/arbitrum/ArbAdapter.sol';
import {ArbitrumAdapterTestnet} from '../contract_extensions/ArbitrumAdapter.sol';

library ArbAdapterDeploymentHelper {
  struct ArbAdapterArgs {
    BaseAdapterArgs baseArgs;
    address inbox;
    address destinationCCC;
  }

  function getAdapterCode(ArbAdapterArgs memory arbArgs) internal pure returns (bytes memory) {
    bytes memory creationCode = arbArgs.baseArgs.isTestnet
      ? type(ArbitrumAdapterTestnet).creationCode
      : type(ArbAdapter).creationCode;

    return
      abi.encodePacked(
        creationCode,
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

abstract contract BaseDeployArbAdapter is BaseAdapterScript {
  function INBOX() internal view virtual returns (address) {
    return address(0);
  }

  function _getConstructorArgs(
    address crossChainController,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal view returns (ArbAdapterDeploymentHelper.ArbAdapterArgs memory) {
    require(crossChainController != address(0), 'CCC needs to be deployed');

    DeployerHelpers.Addresses memory remoteAddresses;
    if (isTestnet()) {
      if (TRANSACTION_NETWORK() == TestNetChainIds.ETHEREUM_SEPOLIA) {
        remoteAddresses = _getAddresses(TestNetChainIds.ARBITRUM_SEPOLIA);
        require(
          remoteAddresses.crossChainController != address(0),
          'Arbitrum CCC must be deployed'
        );
        require(INBOX() != address(0), 'Arbitrum inbox can not be 0');
      }
    } else {
      if (TRANSACTION_NETWORK() == ChainIds.ETHEREUM) {
        remoteAddresses = _getAddresses(ChainIds.ARBITRUM);
        require(
          remoteAddresses.crossChainController != address(0),
          'Arbitrum CCC must be deployed'
        );
        require(INBOX() != address(0), 'Arbitrum inbox can not be 0');
      }
    }

    return
      ArbAdapterDeploymentHelper.ArbAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: crossChainController,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        inbox: INBOX(),
        destinationCCC: remoteAddresses.crossChainController
      });
  }

  function _deployAdapter(
    DeployerHelpers.Addresses memory addresses,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (address) {
    ArbAdapterDeploymentHelper.ArbAdapterArgs memory constructorArgs = _getConstructorArgs(
      addresses.crossChainController,
      trustedRemotes
    );

    return
      Create2Utils.create2Deploy(
        keccak256(abi.encode(SALT())),
        ArbAdapterDeploymentHelper.getAdapterCode(constructorArgs)
      );
  }
}
