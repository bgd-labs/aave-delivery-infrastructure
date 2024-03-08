// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../../src/contracts/interfaces/ICrossChainForwarder.sol';

import '../BaseScript.sol';

abstract contract BaseSendMessage is BaseScript {
  function DESTINATION_NETWORK() public view virtual returns (uint256);

  function getDestinationAddress() public view virtual returns (address) {
    return _getAddresses(DESTINATION_NETWORK()).mockDestination;
  }

  function getGasLimit() public view virtual returns (uint256) {
    return 300_000;
  }

  function getMessage() public view virtual returns (bytes memory) {
    return abi.encode('This is a test message...');
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

contract Ethereum is BaseSendMessage {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Ethereum_testnet is BaseSendMessage {
  function getMessage() public view virtual override returns (bytes memory) {
    return abi.encode('This is a test message from the Sepolia testnet to the Mumbai testnet...');
  }

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function DESTINATION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }
}
