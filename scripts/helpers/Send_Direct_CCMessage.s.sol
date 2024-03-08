// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';

abstract contract BaseSendDirectMessage is BaseScript {
  function DESTINATION_NETWORK() public view virtual returns (uint256);

  function getDestinationAddress() public view virtual returns (address) {
    return _getAddresses(DESTINATION_NETWORK()).mockDestination;
  }

  function getGasLimit() public view virtual returns (uint256) {
    return 150_000;
  }

  function getMessage() public view virtual returns (bytes memory) {
    return abi.encode('some random message');
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    uint256 destinationChainId = _getAddresses(DESTINATION_NETWORK()).chainId;

    ICrossChainForwarder(addresses.crossChainController).forwardMessage(
      destinationChainId,
      getDestinationAddress(),
      getGasLimit(),
      getMessage()
    );
  }
}

contract Ethereum is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Avalanche is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Ethereum_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}

contract Avalanche_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
