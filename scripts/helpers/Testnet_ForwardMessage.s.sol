// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseScript.sol';
import './mocks/MockDelegateCallProxy.sol';
import '../../src/contracts/libs/EncodingUtils.sol';
import {TestNetChainIds} from '../contract_extensions/TestNetChainIds.sol';
import {AddressAliasHelper} from 'nitro-contracts/libraries/AddressAliasHelper.sol';
import {IBaseAdapter} from '../../src/contracts/adapters/IBaseAdapter.sol';

/**
 * @dev This script directly calls the adapter from a proxy via delegatecall, skipping the CrossChainController.
 */
contract Testnet_ForwardMessage is BaseScript {
  /// @dev This must be modified to run the script with the chosen origin chain.
  uint256 constant ORIGIN_CHAIN_ID = TestNetChainIds.ETHEREUM_GOERLI;

  /// @dev This must be modified to run the script with the chosen target chain.
  uint256 constant DESTINATION_CHAIN_ID = TestNetChainIds.BASE_GOERLI;

  /// @dev Replace this to use a different proxy, or set it to zero to deploy a new one and end execution.
  /// Note that this proxy MUST be the trusted remote on the receiver side.
  MockDelegateCallProxy proxy =
    MockDelegateCallProxy(payable(0x9b71641EBDf6a4106Eee27360e4eB2ee62f0d879));

  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ORIGIN_CHAIN_ID;
  }

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    // Ensure the proper origin chain ID was set.
    require(ORIGIN_CHAIN_ID != 0, 'Testnet_ForwardMessage: Origin Chain ID must be set');

    // Ensure the proper destination chain ID was set.
    require(DESTINATION_CHAIN_ID != 0, 'Testnet_ForwardMessage: Destination Chain ID must be set');

    DeployerHelpers.Addresses memory targetAddresses = _getAddresses(DESTINATION_CHAIN_ID);

    if (address(proxy) == address(0)) {
      proxy = new MockDelegateCallProxy();

      /// @dev We return here since this proxy must now be the trusted remote on the receiver side.
      return;
    }

    (
      address originAdapter,
      address targetAdapter,
      address mockDestination
    ) = _getNeededTargetAddresses(addresses, targetAddresses);

    EncodedEnvelope memory mockEnvelope = EnvelopeUtils.encode(
      Envelope({
        nonce: 0,
        origin: address(this),
        destination: mockDestination,
        originChainId: ORIGIN_CHAIN_ID,
        destinationChainId: DESTINATION_CHAIN_ID,
        message: abi.encode(hex'04546b')
      })
    );

    Transaction memory mockTransaction = Transaction({
      nonce: 0,
      encodedEnvelope: mockEnvelope.data
    });
    console.log('dest chain id', DESTINATION_CHAIN_ID);
    bytes memory encodedAdapterCall = abi.encodeCall(
      IBaseAdapter.forwardMessage,
      (targetAdapter, 200_000, DESTINATION_CHAIN_ID, TransactionUtils.encode(mockTransaction).data)
    );

    //    if (address(proxy).balance < 0.04 ether) {
    //      payable(address(proxy)).transfer(0.05 ether);
    //    }

    proxy.execute(originAdapter, encodedAdapterCall);
  }

  function _getNeededTargetAddresses(
    DeployerHelpers.Addresses memory originAddresses,
    DeployerHelpers.Addresses memory targetAddresses
  ) internal pure returns (address, address, address) {
    require(
      ORIGIN_CHAIN_ID == TestNetChainIds.ETHEREUM_GOERLI,
      'Testnet_ForwardMessage: Origin chain not supported'
    );

    address originAdapter;
    address targetAdapter;

    if (DESTINATION_CHAIN_ID == TestNetChainIds.POLYGON_MUMBAI) {
      originAdapter = originAddresses.polAdapter;
      targetAdapter = targetAddresses.polAdapter;
    } else if (DESTINATION_CHAIN_ID == TestNetChainIds.ARBITRUM_GOERLI) {
      originAdapter = originAddresses.arbAdapter;
      targetAdapter = targetAddresses.arbAdapter;
    } else if (DESTINATION_CHAIN_ID == TestNetChainIds.OPTIMISM_GOERLI) {
      originAdapter = originAddresses.opAdapter;
      targetAdapter = targetAddresses.opAdapter;
    } else if (DESTINATION_CHAIN_ID == TestNetChainIds.METIS_TESTNET) {
      originAdapter = originAddresses.metisAdapter;
      targetAdapter = targetAddresses.metisAdapter;
    } else if (DESTINATION_CHAIN_ID == TestNetChainIds.BASE_GOERLI) {
      originAdapter = originAddresses.baseAdapter;
      targetAdapter = targetAddresses.baseAdapter;
    } else {
      revert('Testnet_ForwardMessage: Target adapter not supported');
    }

    return (originAdapter, targetAdapter, targetAddresses.mockDestination);
  }
}
