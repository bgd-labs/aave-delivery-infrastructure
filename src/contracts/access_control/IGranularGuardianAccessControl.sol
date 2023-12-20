// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Envelope} from '../libs/EncodingUtils.sol';

/**
 * @title IGranularGuardianAccessControl
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the GranularGuardianAccessControl contract
 */
interface IGranularGuardianAccessControl {
  /**
   * @notice method called to re forward a previously sent envelope.
   * @param envelope the Envelope type data
   * @param gasLimit gas cost on receiving side of the message
   * @return the transaction id that has the retried envelope
   * @dev This method will send an existing Envelope using a new Transaction.
   * @dev This method should be used when the intention is to send the Envelope as if it was a new message. This way on
          the Receiver side it will start from 0 to count for the required confirmations. (usual use case would be for
          when an envelope has been invalidated on Receiver side, and needs to be retried as a new message)
   */
  function retryEnvelope(Envelope memory envelope, uint256 gasLimit) external returns (bytes32);

  /**
   * @notice method to retry forwarding an already forwarded transaction
   * @param encodedTransaction the encoded Transaction data
   * @param gasLimit limit of gas to spend on forwarding per bridge
   * @param bridgeAdaptersToRetry list of bridge adapters to be used for the transaction forwarding retry
   * @dev This method will send an existing Transaction with its Envelope to the specified adapters.
   * @dev Should be used when some of the bridges on the initial forwarding did not work (out of gas),
          and we want the Transaction with Envelope to still account for the required confirmations on the Receiver side
   */
  function retryTransaction(
    bytes memory encodedTransaction,
    uint256 gasLimit,
    address[] memory bridgeAdaptersToRetry
  ) external;
}
