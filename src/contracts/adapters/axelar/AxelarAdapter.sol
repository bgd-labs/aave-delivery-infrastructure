// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IAxelarAdapter, IAxelarGateway, IAxelarGasService} from './IAxelarAdapter.sol';
import {SafeCast} from 'openzeppelin-contracts/contracts/utils/math/SafeCast.sol';
import {BaseAdapter, IBaseAdapter} from '../BaseAdapter.sol';
import {ChainIds} from '../../libs/ChainIds.sol';
import {Errors} from '../../libs/Errors.sol';

library StringUtils {
  function eq(string memory a, string memory b) internal pure returns (bool) {
    return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
  }
}

/**
 * @title AxekarAdapter
 * @author BGD Labs
 * @notice Axelar bridge adapter. Used to send and receive messages cross chain
 * @dev it uses the eth balance of CrossChainController contract to pay for message bridging as the method to bridge
        is called via delegate call
 */
contract AxelarAdapter is BaseAdapter, IAxelarAdapter {
  using StringUtils for string;

  IAxelarGateway public immutable AXELAR_GATEWAY;

  IAxelarGasService public immutable AXELAR_GAS_SERVICE;

  /**
   * @notice constructor for the Axelar adapter
   * @param gateway address of the axelar gateway endpoint on the current chain where adapter is deployed
   * @param gasService address of the axelar gas service endpoint on the current chain where adapter is deployed
   * @param crossChainController address of the contract that manages cross chain infrastructure
   * @param providerGasLimit base gas limit used by the bridge adapter
   * @param trustedRemotes array of objects with chain id and origin addresses which will be allowed to send messages to this adapter
   */
  constructor(
    address gateway,
    address gasService,
    address crossChainController,
    uint256 providerGasLimit,
    TrustedRemotesConfig[] memory trustedRemotes
  ) BaseAdapter(crossChainController, providerGasLimit, 'Axelar adapter', trustedRemotes) {
    require(gateway != address(0), Errors.INVALID_AXELAR_GATEWAY);
    require(gasService != address(0), Errors.INVALID_AXELAR_GAS_SERVICE);
    AXELAR_GATEWAY = IAxelarGateway(gateway);
    AXELAR_GAS_SERVICE = IAxelarGasService(gasService);
  }

  /// @inheritdoc IBaseAdapter
  function forwardMessage(
    address receiver,
    uint256 executionGasLimit,
    uint256 destinationChainId,
    bytes calldata message
  ) external returns (address, uint256) {
    // TODO: transform to native chain ids
    uint256 gasEstimate = AXELAR_GAS_SERVICE.estimateGasFee(
      destinationChain,
      destinationAddress,
      payload,
      GAS_LIMIT,
      new bytes(0)
    );

    AXELAR_GAS_SERVICE.payGas{value: gasEstimate}(
      address(this),
      destinationChain,
      destinationAddress,
      payload,
      GAS_LIMIT,
      true,
      msg.sender,
      new bytes(0)
    );
    AXELAR_GATEWAY.callContract(destinationChain, destinationAddress, payload);
  }

  // TODO: not clear on what the receiving method should be like

  /// @inheritdoc IBaseAdapter
  function nativeToInfraChainId(uint256 nativeChainId) public pure override returns (uint256) {
    return nativeChainId;
  }

  /// @inheritdoc IBaseAdapter
  function infraToNativeChainId(uint256 infraChainId) public pure override returns (uint256) {
    return infraChainId;
  }

  /// @inheritdoc IAxelarAdapter
  function axelarNativeToInfraChainId(
    string memory nativeChainId
  ) public pure virtual returns (uint256) {
    if (nativeChainId.eq('Ethereum')) {
      return ChainIds.ETHEREUM;
    } else if (nativeChainId.eq('Avalanche')) {
      return ChainIds.AVALANCHE;
    } else if (nativeChainId.eq('Polygon')) {
      return ChainIds.POLYGON;
    } else if (nativeChainId.eq('arbitrum')) {
      return ChainIds.ARBITRUM;
    } else if (nativeChainId.eq('optimism')) {
      return ChainIds.OPTIMISM;
    } else if (nativeChainId.eq('base')) {
      return ChainIds.BASE;
    } else if (nativeChainId.eq('binance')) {
      return ChainIds.BNB;
    } else if (nativeChainId.eq('scroll')) {
      return ChainIds.SCROLL;
    } else if (nativeChainId.eq('celo')) {
      return ChainIds.CELO;
    } else if (nativeChainId.eq('Fantom')) {
      return ChainIds.FANTOM;
    } else {
      return 0;
    }
  }

  /// @inheritdoc IAxelarAdapter
  function axelarInfraToNativeChainId(
    uint256 infraChainId
  ) public pure virtual returns (string memory) {
    if (infraChainId == ChainIds.ETHEREUM) {
      return 'Ethereum';
    } else if (infraChainId == ChainIds.AVALANCHE) {
      return 'Avalanche';
    } else if (infraChainId == ChainIds.POLYGON) {
      return 'Polygon';
    } else if (infraChainId == ChainIds.ARBITRUM) {
      return 'arbitrum';
    } else if (infraChainId == ChainIds.OPTIMISM) {
      return 'optimism';
    } else if (infraChainId == ChainIds.FANTOM) {
      return 'Fantom';
    } else if (infraChainId == ChainIds.BASE) {
      return 'base';
    } else if (infraChainId == ChainIds.SCROLL) {
      return 'scroll';
    } else if (infraChainId == ChainIds.BNB) {
      return 'binance';
    } else if (infraChainId == ChainIds.CELO) {
      return 'celo';
    } else {
      return '';
    }
  }
}
