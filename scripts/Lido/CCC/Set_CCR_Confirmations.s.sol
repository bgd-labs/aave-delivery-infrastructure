// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CrossChainController, ICrossChainController} from '../../../src/contracts/CrossChainController.sol';
import {ICrossChainReceiver} from '../../../src/contracts/interfaces/ICrossChainReceiver.sol';

import '../BaseScript.sol';

abstract contract BaseSetCCRConfirmations is BaseScript {
  struct ConfirmationsByChain {
    uint8 confirmations;
    uint256 chainId;
  }

  function getConfirmationsByChainIds() public virtual returns (ConfirmationsByChain[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    ConfirmationsByChain[] memory confirmationsByChain = getConfirmationsByChainIds();
    ICrossChainReceiver.ConfirmationInput[]
    memory confirmationsInput = new ICrossChainReceiver.ConfirmationInput[](
      confirmationsByChain.length
    );

    for (uint256 i = 0; i < confirmationsByChain.length; i++) {
      confirmationsInput[i] = ICrossChainReceiver.ConfirmationInput({
        chainId: confirmationsByChain[i].chainId,
        requiredConfirmations: confirmationsByChain[i].confirmations
      });
    }

    ICrossChainReceiver(addresses.crossChainController).updateConfirmations(confirmationsInput);
  }
}

// nothing to receive
contract Ethereum is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](0);

    return chainIds;
  }
}

// 3/4 consensus
contract Polygon is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 3});

    return chainIds;
  }
}

// 3/4 consensus
contract Binance is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 3});

    return chainIds;
  }
}

// nothing to receive
contract Ethereum_testnet is Ethereum {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](0);

    return chainIds;
  }
}

// 2/3 consensus
contract Polygon_testnet is Polygon {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: TestNetChainIds.ETHEREUM_SEPOLIA, confirmations: 2});

    return chainIds;
  }
}

contract Binance_testnet is Binance {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function getConfirmationsByChainIds() public virtual override returns (ConfirmationsByChain[] memory) {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: TestNetChainIds.ETHEREUM_SEPOLIA, confirmations: 2});

    return chainIds;
  }
}
