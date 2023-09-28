// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import './BaseCrossChainController.t.sol';
import '../scripts/create_payloads/Payload_SolveEmergencyPrePopulated.s.sol';
import {ChainIds} from '../src/contracts/libs/ChainIds.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {ICLEmergencyOracle} from '../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../src/contracts/CrossChainControllerWithEmergencyMode.sol';

contract PayloadScriptsTest is Test {
  address public constant CL_EMERGENCY_ORACLE = address(12345);
  address public constant OWNER = address(123);
  address public constant GUARDIAN = address(1234);
  address public constant BRIDGE_ADAPTER = address(123456);
  bytes32 public constant PROXY_ADMIN_SALT = keccak256('proxy admin salt');
  bytes32 public constant CROSS_CHAIN_CONTROLLER_SALT = keccak256('cross chain controller salt');
  uint8 public constant CONFIRMATIONS = 1;

  TransparentProxyFactory public proxyFactory;
  IBaseCrossChainController public crossChainController;
  address public crossChainControllerImpl;
  address public proxyAdmin;

  function _deployControllerImplementation() internal returns (address) {
    return address(new CrossChainControllerWithEmergencyMode(CL_EMERGENCY_ORACLE));
  }

  function _getEncodedInitializer(
    address owner,
    address guardian,
    ICrossChainReceiver.ConfirmationInput[] memory initialRequiredConfirmations,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove
  ) internal pure returns (bytes memory) {
    return
      abi.encodeWithSelector(
        ICrossChainControllerWithEmergencyMode.initialize.selector,
        owner,
        guardian,
        CL_EMERGENCY_ORACLE,
        initialRequiredConfirmations,
        receiverBridgeAdaptersToAllow,
        forwarderBridgeAdaptersToEnable,
        sendersToApprove
      );
  }

  function setUp() public {
    proxyFactory = new TransparentProxyFactory();

    // deploy admin if not deployed before
    proxyAdmin = proxyFactory.createDeterministicProxyAdmin(OWNER, PROXY_ADMIN_SALT);

    uint256[] memory chainIds = _chainIds();

    /* ----------------------------- Receiver Config ---------------------------- */

    // Adapters to allow
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        chainIds.length
      );

    for (uint256 i = 0; i < chainIds.length; ++i) {
      receiverBridgeAdaptersToAllow[i] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: address(uint160(BRIDGE_ADAPTER) + uint160(i)),
        chainIds: chainIds
      });
    }

    // Confirmations
    ICrossChainReceiver.ConfirmationInput[]
      memory initialRequiredConfirmations = new ICrossChainReceiver.ConfirmationInput[](
        chainIds.length
      );
    for (uint256 i = 0; i < chainIds.length; ++i) {
      ICrossChainReceiver.ConfirmationInput memory confirmation = ICrossChainReceiver
        .ConfirmationInput({chainId: chainIds[i], requiredConfirmations: CONFIRMATIONS});

      initialRequiredConfirmations[i] = confirmation;
    }

    /* ---------------------------- Forwarder Config ---------------------------- */

    // Senders to approve
    address[] memory sendersToApprove = new address[](1);
    sendersToApprove[0] = address(102);

    // Forwarder adapters to enable
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        chainIds.length ** 2
      );

    for (uint256 i = 0; i < chainIds.length; ++i) {
      address currentChainAdapter = address(uint160(uint256(keccak256('currentChainAdapter')) + i));
      address destChainAdapter = address(110 + uint160(i));

      for (uint256 j = 0; j < chainIds.length; ++j) {
        forwarderBridgeAdaptersToEnable[i * chainIds.length + j] = ICrossChainForwarder
          .ForwarderBridgeAdapterConfigInput({
            currentChainBridgeAdapter: currentChainAdapter,
            destinationBridgeAdapter: destChainAdapter,
            destinationChainId: chainIds[j]
          });
      }

      vm.mockCall(
        currentChainAdapter,
        abi.encodeWithSelector(IBaseAdapter.setupPayments.selector),
        abi.encode()
      );
    }

    // Deployment
    crossChainControllerImpl = _deployControllerImplementation();
    crossChainController = IBaseCrossChainController(
      proxyFactory.createDeterministic(
        crossChainControllerImpl,
        proxyAdmin,
        _getEncodedInitializer(
          OWNER,
          GUARDIAN,
          initialRequiredConfirmations,
          receiverBridgeAdaptersToAllow,
          forwarderBridgeAdaptersToEnable,
          sendersToApprove
        ),
        CROSS_CHAIN_CONTROLLER_SALT
      )
    );
  }

  function test_solveEmergencyPrePopulated() public {
    SolveEmergencyPayloadPrePopulated payload = new SolveEmergencyPayloadPrePopulated(
      address(crossChainController)
    );
    uint256[] memory chainIds = _chainIds();
    vm.etch(GUARDIAN, address(payload).code);

    // Pre-checks
    for (uint256 i = 0; i < chainIds.length; ++i) {
      ICrossChainReceiver.ReceiverConfiguration memory receiverConfig = crossChainController
        .getConfigurationByChain(chainIds[i]);
      assertEq(receiverConfig.validityTimestamp, 0);
      assertEq(
        crossChainController.getReceiverBridgeAdaptersByChain(chainIds[i]).length,
        chainIds.length
      );
      assertEq(
        crossChainController.getForwarderBridgeAdaptersByChain(chainIds[i]).length,
        chainIds.length
      );
    }

    // Execute payload as guardian (as if it were via delegatecall)
    vm.mockCall(
      CL_EMERGENCY_ORACLE,
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(uint80(0), int256(1), 0, 0, uint80(0))
    );
    SolveEmergencyPayloadPrePopulated(GUARDIAN).execute();

    // Post-checks
    for (uint256 i = 0; i < chainIds.length; ++i) {
      ICrossChainReceiver.ReceiverConfiguration memory receiverConfig = crossChainController
        .getConfigurationByChain(chainIds[i]);

      assertEq(receiverConfig.validityTimestamp, block.timestamp);
      assertEq(crossChainController.getReceiverBridgeAdaptersByChain(chainIds[i]).length, 0);
      assertEq(crossChainController.getForwarderBridgeAdaptersByChain(chainIds[i]).length, 0);
    }
  }

  function _chainIds() internal pure returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](9);
    chainIds[0] = ChainIds.ETHEREUM;
    chainIds[1] = ChainIds.POLYGON;
    chainIds[2] = ChainIds.AVALANCHE;
    chainIds[3] = ChainIds.ARBITRUM;
    chainIds[4] = ChainIds.OPTIMISM;
    chainIds[5] = ChainIds.FANTOM;
    chainIds[6] = ChainIds.HARMONY;
    chainIds[7] = ChainIds.METIS;
    chainIds[8] = ChainIds.BNB;
    return chainIds;
  }
}
