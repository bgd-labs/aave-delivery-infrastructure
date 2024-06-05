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

  function DESTINATION_CCC() internal view virtual returns (address) {
    return address(0);
  }

  function _getConstructorArgs(
    address transactionNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal view returns (ArbAdapterDeploymentHelper.ArbAdapterArgs memory) {
    require(transactionNetworkCCC != address(0), 'CCC needs to be deployed');

    require(trustedRemotes.length == 1, 'Arb adapter can only have one remote');
    if (
      TRANSACTION_NETWORK() == ChainIds.ETHEREUM ||
      TRANSACTION_NETWORK() == TestNetChainIds.ETHEREUM_SEPOLIA
    ) {
      require(DESTINATION_CCC() != address(0), 'Arbitrum CCC must be deployed');
      require(INBOX() != address(0), 'Arbitrum inbox can not be 0');
    }

    return
      ArbAdapterDeploymentHelper.ArbAdapterArgs({
        baseArgs: BaseAdapterArgs({
          crossChainController: transactionNetworkCCC,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: trustedRemotes,
          isTestnet: isTestnet()
        }),
        inbox: INBOX(),
        destinationCCC: DESTINATION_CCC()
      });
  }

  function _deployAdapter(
    address currentNetworkCCC,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override returns (address) {
    ArbAdapterDeploymentHelper.ArbAdapterArgs memory constructorArgs = _getConstructorArgs(
      currentNetworkCCC,
      trustedRemotes
    );

    return
      Create2Utils.create2Deploy(
        keccak256(abi.encode(SALT())),
        ArbAdapterDeploymentHelper.getAdapterCode(constructorArgs)
      );
  }
}
