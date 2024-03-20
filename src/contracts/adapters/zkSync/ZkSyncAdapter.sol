// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {AddressAliasHelper} from './libs/AddressAliasHelper.sol';
import {Errors} from '../../libs/Errors.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {IZkSyncAdapter, IMailbox, IClOracle} from './IZkSyncAdapter.sol';

/**
 * @title ZkSyncAdapter
 * @author BGD Labs
 * @notice ZkSync bridge adapter. Used to send and receive messages cross chain between Ethereum and ZkSync
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 * @dev note that this adapter can only be used for the communication path ETHEREUM -> ZKSYNC
 * @dev uses Chainlink oracle to get gas price information: https://data.chain.link/feeds/ethereum/mainnet/fast-gas-gwei
 */
contract ZkSyncAdapter is IZkSyncAdapter, BaseAdapter {
  /// @inheritdoc IZkSyncAdapter
  IMailbox public immutable MAILBOX;

  /// @inheritdoc IZkSyncAdapter
  IClOracle public immutable CL_GAS_PRICE_ORACLE;

  /// @inheritdoc IZkSyncAdapter
  uint256 public constant REQUIRED_L1_TO_L2_GAS_PER_PUBDATA_LIMIT = 800;

  /// @inheritdoc IZkSyncAdapter
  address public immutable REFUND_ADDRESS_L2;

  /**
   * @param crossChainController address of the cross chain controller that will use this bridge adapter
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes list of remote configurations to set as trusted
   */
  constructor(
    address crossChainController,
    address mailBox,
    address clGasPriceOracle,
    address refundAddress,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'ZkSync native adapter', trustedRemotes) {
    require(mailBox != address(0), Errors.ZK_SYNC_MAILBOX_CANT_BE_ADDRESS_0);
    require(clGasPriceOracle != address(0), Errors.CL_GAS_PRICE_ORACLE_CANT_BE_ADDRESS_0);
    CL_GAS_PRICE_ORACLE = IClOracle(clGasPriceOracle);
    MAILBOX = IMailbox(mailBox);
    REFUND_ADDRESS_L2 = refundAddress;
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    require(
      isDestinationChainIdSupported(destinationChainId),
      Errors.DESTINATION_CHAIN_ID_NOT_SUPPORTED
    );
    require(receiver != address(0), Errors.RECEIVER_NOT_SET);

    uint256 totalGasLimit = executionGasLimit + BASE_GAS_LIMIT;

    (, int256 answer, , , ) = CL_GAS_PRICE_ORACLE.latestRoundData();

    uint256 cost = MAILBOX.l2TransactionBaseCost(
      uint256(answer),
      totalGasLimit,
      REQUIRED_L1_TO_L2_GAS_PER_PUBDATA_LIMIT
    );

    require(address(this).balance >= cost, Errors.NOT_ENOUGH_VALUE_TO_PAY_BRIDGE_FEES);

    bytes memory destinationCalldata = abi.encodeWithSelector(
      IZkSyncAdapter.receiveMessage.selector,
      message
    );

    bytes32 canonicalTxHash = MAILBOX.requestL2Transaction{value: cost}(
      receiver,
      0,
      destinationCalldata,
      totalGasLimit,
      REQUIRED_L1_TO_L2_GAS_PER_PUBDATA_LIMIT,
      new bytes[](0),
      REFUND_ADDRESS_L2 // TODO: is it correct to pass l2 address? Should it be aliased?
    );

    return (address(MAILBOX), uint256(canonicalTxHash));
  }

  /// @inheritdoc IZkSyncAdapter
  function receiveMessage(bytes calldata message) external {
    uint256 originChainId = getOriginChainId();
    address srcAddress = AddressAliasHelper.undoL1ToL2Alias(msg.sender);
    require(
      _trustedRemotes[originChainId] == srcAddress && srcAddress != address(0),
      Errors.REMOTE_NOT_TRUSTED
    );

    _registerReceivedMessage(message, originChainId);
  }

  /// @inheritdoc IZkSyncAdapter
  function getOriginChainId() public view virtual returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  /// @inheritdoc IZkSyncAdapter
  function isDestinationChainIdSupported(uint256 chainId) public view virtual returns (bool) {
    return chainId == ChainIds.ZK_SYNC;
  }

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }
}
