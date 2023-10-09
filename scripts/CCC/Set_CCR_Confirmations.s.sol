// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {CrossChainController, ICrossChainController} from '../../src/contracts/CrossChainController.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';

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

contract Ethereum is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](2);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.POLYGON, confirmations: 3});
    chainIds[1] = ConfirmationsByChain({chainId: ChainIds.AVALANCHE, confirmations: 2});

    return chainIds;
  }
}

contract Polygon is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 3});

    return chainIds;
  }
}

contract Avalanche is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Optimism is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Arbitrum is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Metis is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Binance is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Base is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Gnosis is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Ethereum_testnet is Ethereum {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](2);
    chainIds[0] = ConfirmationsByChain({chainId: TestNetChainIds.POLYGON_MUMBAI, confirmations: 3});
    chainIds[1] = ConfirmationsByChain({chainId: TestNetChainIds.AVALANCHE_FUJI, confirmations: 3});

    return chainIds;
  }
}

contract Polygon_testnet is Polygon {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_SEPOLIA,
      confirmations: 3
    });

    return chainIds;
  }
}

contract Avalanche_testnet is Avalanche {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_SEPOLIA,
      confirmations: 3
    });

    return chainIds;
  }
}

contract Optimism_testnet is Optimism {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.OPTIMISM_GOERLI;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_GOERLI,
      confirmations: 1
    });

    return chainIds;
  }
}

contract Arbitrum_testnet is Arbitrum {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.ARBITRUM_GOERLI;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_GOERLI,
      confirmations: 1
    });

    return chainIds;
  }
}

contract Metis_testnet is Metis {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_GOERLI,
      confirmations: 1
    });

    return chainIds;
  }
}

contract Binance_testnet is Binance {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_SEPOLIA,
      confirmations: 2
    });

    return chainIds;
  }
}

contract Base_testnet is Base {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.BASE_GOERLI;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_GOERLI,
      confirmations: 1
    });

    return chainIds;
  }
}

contract Gnosis_testnet is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() public pure virtual override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({
      chainId: TestNetChainIds.ETHEREUM_GOERLI,
      confirmations: 3
    });

    return chainIds;
  }
}
