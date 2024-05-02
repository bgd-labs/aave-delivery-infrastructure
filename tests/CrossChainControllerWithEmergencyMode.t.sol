// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseCrossChainController.t.sol';
import {ICLEmergencyOracle} from '../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';
import {CrossChainControllerWithEmergencyMode, ICrossChainControllerWithEmergencyMode} from '../src/contracts/CrossChainControllerWithEmergencyMode.sol';

contract CrossChainControllerWithEmergencyModeTest is BaseCrossChainControllerTest {
  address public constant CL_EMERGENCY_ORACLE = address(65536 + 12345);
  event CLEmergencyOracleUpdated(address indexed newChainlinkEmergencyOracle);

  function _deployControllerImplementation() internal override returns (address) {
    return address(new CrossChainControllerWithEmergencyMode(CL_EMERGENCY_ORACLE));
  }

  function _getEncodedInitializer(
    address owner,
    address guardian,
    ICrossChainReceiver.ConfirmationInput[] memory initialRequiredConfirmations,
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory receiverBridgeAdaptersToAllow,
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory forwarderBridgeAdaptersToEnable,
    address[] memory sendersToApprove
  ) internal pure override returns (bytes memory) {
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

  function testInitializeWithZeroCLEmergencyOracleAddress() public {
    // receiver configs
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        1
      );
    receiverBridgeAdaptersToAllow[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: BRIDGE_ADAPTER,
      chainIds: chainIds
    });

    ICrossChainReceiver.ConfirmationInput memory confirmation = ICrossChainReceiver
      .ConfirmationInput({chainId: ChainIds.ETHEREUM, requiredConfirmations: CONFIRMATIONS});
    ICrossChainReceiver.ConfirmationInput[]
      memory initialRequiredConfirmations = new ICrossChainReceiver.ConfirmationInput[](1);
    initialRequiredConfirmations[0] = confirmation;

    // forwarder configs
    address[] memory sendersToApprove = new address[](1);
    sendersToApprove[0] = address(65536 + 102);
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        1
      );
    forwarderBridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: address(65536 + 103),
      destinationBridgeAdapter: address(65536 + 110),
      destinationChainId: ChainIds.POLYGON
    });

    vm.expectRevert(bytes(Errors.INVALID_EMERGENCY_ORACLE));
    proxyFactory.createDeterministic(
      crossChainControllerImpl,
      proxyAdmin,
      abi.encodeWithSelector(
        ICrossChainControllerWithEmergencyMode.initialize.selector,
        OWNER,
        GUARDIAN,
        address(0),
        initialRequiredConfirmations,
        receiverBridgeAdaptersToAllow,
        forwarderBridgeAdaptersToEnable,
        sendersToApprove
      ),
      CROSS_CHAIN_CONTROLLER_SALT
    );
  }

  function testCLEmergencyOracle() public {
    assertEq(
      ICrossChainControllerWithEmergencyMode(address(crossChainController))
        .getChainlinkEmergencyOracle(),
      CL_EMERGENCY_ORACLE
    );
  }

  function testSolveEmergency() public {
    // receiver config
    uint256[] memory originChainIds = new uint256[](1);
    originChainIds[0] = ChainIds.ETHEREUM;
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        1
      );
    receiverBridgeAdaptersToAllow[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: address(65536 + 201),
      chainIds: originChainIds
    });
    uint8 newConfirmation = 1;
    ICrossChainReceiver.ConfirmationInput memory confirmation = ICrossChainReceiver
      .ConfirmationInput({chainId: ChainIds.ETHEREUM, requiredConfirmations: newConfirmation});
    ICrossChainReceiver.ConfirmationInput[]
      memory newConfirmations = new ICrossChainReceiver.ConfirmationInput[](1);
    newConfirmations[0] = confirmation;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToDisallow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        1
      );
    receiverBridgeAdaptersToDisallow[0].bridgeAdapter = BRIDGE_ADAPTER;

    receiverBridgeAdaptersToDisallow[0].chainIds = new uint256[](2);
    receiverBridgeAdaptersToDisallow[0].chainIds[0] = 1;
    receiverBridgeAdaptersToDisallow[0].chainIds[1] = 137;

    uint120 newValidityTimestamp = uint120(block.timestamp + 5);
    ICrossChainReceiver.ValidityTimestampInput[]
      memory newValidityTimestamps = new ICrossChainReceiver.ValidityTimestampInput[](1);
    newValidityTimestamps[0] = ICrossChainReceiver.ValidityTimestampInput({
      chainId: ChainIds.ETHEREUM,
      validityTimestamp: newValidityTimestamp
    });

    // forwarder config
    address[] memory sendersToApprove = new address[](1);
    sendersToApprove[0] = address(65536 + 202);
    address[] memory sendersToRemove = new address[](1);
    sendersToRemove[0] = address(65536 + 102);
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        1
      );
    forwarderBridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: address(65536 + 203),
      destinationBridgeAdapter: address(65536 + 210),
      destinationChainId: ChainIds.POLYGON
    });
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarderBridgeAdaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](
        1
      );
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.POLYGON;
    forwarderBridgeAdaptersToDisable[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: address(65536 + 103),
      chainIds: chainIds
    });

    skip(10);

    hoax(GUARDIAN);
    vm.mockCall(
      CL_EMERGENCY_ORACLE,
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(uint80(0), int256(1), 0, 0, uint80(0))
    );
    vm.mockCall(
      address(65536 + 203),
      abi.encodeWithSelector(IBaseAdapter.setupPayments.selector),
      abi.encode()
    );
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).solveEmergency(
      newConfirmations,
      newValidityTimestamps,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable
    );

    ICrossChainReceiver.ReceiverConfiguration memory receiverConfig = crossChainController
      .getConfigurationByChain(ChainIds.ETHEREUM);
    assertEq(receiverConfig.requiredConfirmation, newConfirmation);
    assertEq(receiverConfig.validityTimestamp, newValidityTimestamp);
    assertEq(
      crossChainController.isReceiverBridgeAdapterAllowed(address(65536 + 201), ChainIds.ETHEREUM),
      true
    );
    assertEq(
      crossChainController.isReceiverBridgeAdapterAllowed(BRIDGE_ADAPTER, ChainIds.ETHEREUM),
      false
    );
    assertEq(crossChainController.isSenderApproved(address(65536 + 202)), true);
    assertEq(crossChainController.isSenderApproved(address(65536 + 102)), false);

    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarderBridgeAdapters = crossChainController
      .getForwarderBridgeAdaptersByChain(ChainIds.POLYGON);

    assertEq(forwarderBridgeAdapters.length, 1);
    assertEq(forwarderBridgeAdapters[0].destinationBridgeAdapter, address(65536 + 210));
    assertEq(forwarderBridgeAdapters[0].currentChainBridgeAdapter, address(65536 + 203));
  }

  function testSolveEmergencyWhenUnreachableConfirmations() public {
    // receiver config
    uint256[] memory originChainIds = new uint256[](1);
    originChainIds[0] = ChainIds.ETHEREUM;
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        1
      );
    receiverBridgeAdaptersToAllow[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: address(65536 + 201),
      chainIds: originChainIds
    });
    uint8 newConfirmation = 3;
    ICrossChainReceiver.ConfirmationInput memory confirmation = ICrossChainReceiver
      .ConfirmationInput({chainId: ChainIds.ETHEREUM, requiredConfirmations: newConfirmation});
    ICrossChainReceiver.ConfirmationInput[]
      memory newConfirmations = new ICrossChainReceiver.ConfirmationInput[](1);
    newConfirmations[0] = confirmation;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToDisallow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        1
      );
    receiverBridgeAdaptersToDisallow[0].bridgeAdapter = BRIDGE_ADAPTER;

    receiverBridgeAdaptersToDisallow[0].chainIds = new uint256[](2);
    receiverBridgeAdaptersToDisallow[0].chainIds[0] = 1;
    receiverBridgeAdaptersToDisallow[0].chainIds[1] = 137;

    uint120 newValidityTimestamp = uint120(block.timestamp + 5);
    ICrossChainReceiver.ValidityTimestampInput[]
      memory newValidityTimestamps = new ICrossChainReceiver.ValidityTimestampInput[](1);
    newValidityTimestamps[0] = ICrossChainReceiver.ValidityTimestampInput({
      chainId: ChainIds.ETHEREUM,
      validityTimestamp: newValidityTimestamp
    });

    // forwarder config
    address[] memory sendersToApprove = new address[](1);
    sendersToApprove[0] = address(65536 + 202);
    address[] memory sendersToRemove = new address[](1);
    sendersToRemove[0] = address(65536 + 102);
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        1
      );
    forwarderBridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: address(65536 + 203),
      destinationBridgeAdapter: address(65536 + 210),
      destinationChainId: ChainIds.POLYGON
    });
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarderBridgeAdaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](
        1
      );
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.POLYGON;
    forwarderBridgeAdaptersToDisable[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: address(65536 + 103),
      chainIds: chainIds
    });

    hoax(GUARDIAN);
    vm.mockCall(
      CL_EMERGENCY_ORACLE,
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(uint80(0), int256(1), 0, 0, uint80(0))
    );
    vm.expectRevert(bytes(Errors.INVALID_REQUIRED_CONFIRMATIONS));
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).solveEmergency(
      newConfirmations,
      newValidityTimestamps,
      receiverBridgeAdaptersToAllow,
      receiverBridgeAdaptersToDisallow,
      sendersToApprove,
      sendersToRemove,
      forwarderBridgeAdaptersToEnable,
      forwarderBridgeAdaptersToDisable
    );
  }

  function testSolveEmergencyWhenNotGuardian() public {
    vm.expectRevert(bytes('ONLY_BY_GUARDIAN'));
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).solveEmergency(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
  }

  function testSolveEmergencyWhenGuardianNotEmergencyMode() public {
    uint80 roundId = uint80(0);
    int256 answer = int256(0);
    uint256 startedAt = 0;
    uint256 updatedAt = 0;
    uint80 answeredInRound = uint80(0);

    hoax(GUARDIAN);
    vm.mockCall(
      CL_EMERGENCY_ORACLE,
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
    );
    vm.expectRevert(bytes(Errors.NOT_IN_EMERGENCY));
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).solveEmergency(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
  }

  function testUpdateCLEmergencyOracle() public {
    address newChainlinkEmergencyOracle = address(65536 + 101);

    hoax(OWNER);
    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated(newChainlinkEmergencyOracle);
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).updateCLEmergencyOracle(
      newChainlinkEmergencyOracle
    );

    assertEq(
      ICrossChainControllerWithEmergencyMode(address(crossChainController))
        .getChainlinkEmergencyOracle(),
      newChainlinkEmergencyOracle
    );
  }

  function testUpdateCLEmergencyOracleWhenNotOwner() public {
    address newChainlinkEmergencyOracle = address(65536 + 101);

    vm.expectRevert(bytes('Ownable: caller is not the owner'));
    ICrossChainControllerWithEmergencyMode(address(crossChainController)).updateCLEmergencyOracle(
      newChainlinkEmergencyOracle
    );

    assertEq(
      ICrossChainControllerWithEmergencyMode(address(crossChainController))
        .getChainlinkEmergencyOracle(),
      CL_EMERGENCY_ORACLE
    );
  }
}
