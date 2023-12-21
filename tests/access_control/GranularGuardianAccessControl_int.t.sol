// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TestUtils} from '../utils/TestUtils.sol';
import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import '../BaseTest.sol';

contract GranularGuardianAccessControlIntTest is BaseTest {
  address public constant RETRY_USER = address(123);
  address public constant SOLVE_EMERGENCY_USER = address(1234);

  address public constant BGD_GUARDIAN = 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF;
  address public constant AAVE_GUARDIAN = 0xCA76Ebd8617a03126B6FB84F9b1c1A0fB71C2633;
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  // list of supported chains
  uint256 destinationChainId = ChainIds.POLYGON;

  GranularGuardianAccessControl public control;

  function setUp() public {
    vm.createSelectFork('ethereum', 18826980);

    control = new GranularGuardianAccessControl(
      AAVE_GUARDIAN,
      RETRY_USER,
      SOLVE_EMERGENCY_USER,
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER
    );

    hoax(BGD_GUARDIAN);
    OwnableWithGuardian(GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER).updateGuardian(
      address(control)
    );
  }

  function test_initialization() public {
    assertEq(control.CROSS_CHAIN_CONTROLLER(), GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER);
    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, AAVE_GUARDIAN), true);
    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), RETRY_USER);
    assertEq(control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0), SOLVE_EMERGENCY_USER);
  }

  function test_retryTx(
    address destination,
    uint256 gasLimit
  )
    public
    generateRetryTxState(
      GovernanceV3Ethereum.EXECUTOR_LVL_1,
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      destinationChainId,
      destination,
      gasLimit
    )
  {
    vm.assume(gasLimit < 300_000);
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: ICrossChainForwarder(GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER)
          .getCurrentTransactionNonce() - 1,
        transactionNonce: ICrossChainForwarder(GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER)
          .getCurrentTransactionNonce() - 1
      })
    );

    ICrossChainForwarder.ChainIdBridgeConfig[] memory bridgeAdaptersByChain = ICrossChainForwarder(
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER
    ).getForwarderBridgeAdaptersByChain(destinationChainId);
    address[] memory bridgeAdaptersToRetry = new address[](1);
    bridgeAdaptersToRetry[0] = bridgeAdaptersByChain[2].currentChainBridgeAdapter;

    vm.startPrank(RETRY_USER);
    control.retryTransaction(extendedTx.transactionEncoded, gasLimit, bridgeAdaptersToRetry);
    vm.stopPrank();
  }

  function test_retryTxWhenWrongCaller() public {
    uint256 gasLimit = 300_000;
    address[] memory bridgeAdaptersToRetry = new address[](0);

    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );

    control.retryTransaction(abi.encode('will not get used'), gasLimit, bridgeAdaptersToRetry);
  }

  //
  //  function test_retryEnvelope(bytes32 mockEnvId) public {
  //    vm.startPrank(RETRY_USER);
  //    //    bytes32 mockEnvId = keccak256(abi.encode('mock envelope id'));
  //    bytes32 envId = _retryEnvelope(mockEnvId);
  //    assertEq(envId, mockEnvId);
  //    vm.stopPrank();
  //  }

  function test_retryEnvelopeWhenWrongCaller(uint256 gasLimit) public {
    Envelope memory envelope;

    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );
    control.retryEnvelope(envelope, gasLimit);
  }

  //  function test_solveEmergency() public {
  //    vm.startPrank(SOLVE_EMERGENCY_USER);
  //    _solveEmergency();
  //    vm.stopPrank();
  //  }

  function test_solveEmergencyWhenWrongCaller() public {
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0xf4cdc679c22cbf47d6de8e836ce79ffdae51f38408dcde3f0645de7634fa607d'
        )
      )
    );
    control.solveEmergency(
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

  function test_updateGuardian(address newGuardian) public {
    vm.startPrank(AAVE_GUARDIAN);
    control.updateGuardian(newGuardian);
    assertEq(IWithGuardian(GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER).guardian(), newGuardian);
    vm.stopPrank();
  }

  function test_updateGuardianWhenWrongCaller(address newGuardian) public {
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
        )
      )
    );
    control.updateGuardian(newGuardian);
  }
  //
  //  function _solveEmergency() public {
  //    ICrossChainReceiver.ConfirmationInput[]
  //      memory newConfirmations = new ICrossChainReceiver.ConfirmationInput[](0);
  //    ICrossChainReceiver.ValidityTimestampInput[]
  //      memory newValidityTimestamp = new ICrossChainReceiver.ValidityTimestampInput[](0);
  //    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
  //      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
  //        0
  //      );
  //    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
  //      memory receiverBridgeAdaptersToDisallow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
  //        0
  //      );
  //    address[] memory sendersToApprove = new address[](0);
  //    address[] memory sendersToRemove = new address[](0);
  //    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
  //      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
  //        0
  //      );
  //    ICrossChainForwarder.BridgeAdapterToDisable[]
  //      memory forwarderBridgeAdaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](
  //        0
  //      );
  //
  //    vm.mockCall(
  //      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
  //      abi.encodeWithSelector(
  //        ICrossChainControllerWithEmergencyMode.solveEmergency.selector,
  //        newConfirmations,
  //        newValidityTimestamp,
  //        receiverBridgeAdaptersToAllow,
  //        receiverBridgeAdaptersToDisallow,
  //        sendersToApprove,
  //        sendersToRemove,
  //        forwarderBridgeAdaptersToEnable,
  //        forwarderBridgeAdaptersToDisable
  //      ),
  //      abi.encode()
  //    );
  //    return
  //      control.solveEmergency(
  //        newConfirmations,
  //        newValidityTimestamp,
  //        receiverBridgeAdaptersToAllow,
  //        receiverBridgeAdaptersToDisallow,
  //        sendersToApprove,
  //        sendersToRemove,
  //        forwarderBridgeAdaptersToEnable,
  //        forwarderBridgeAdaptersToDisable
  //      );
  //  }
  //
  //  function _retryEnvelope(bytes32 mockEnvId) internal returns (bytes32) {
  //    Envelope memory envelope = Envelope({
  //      nonce: 1,
  //      origin: address(12468),
  //      destination: address(2341),
  //      originChainId: 1,
  //      destinationChainId: 137,
  //      message: abi.encode('mock message')
  //    });
  //    uint256 gasLimit = 300_000;
  //
  //    vm.mockCall(
  //      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
  //      abi.encodeWithSelector(ICrossChainForwarder.retryEnvelope.selector, envelope, gasLimit),
  //      abi.encode(mockEnvId)
  //    );
  //    return control.retryEnvelope(envelope, gasLimit);
  //  }
}
