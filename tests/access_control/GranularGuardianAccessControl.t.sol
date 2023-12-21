// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {TestUtils} from '../utils/TestUtils.sol';
import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

contract GranularGuardianAccessControlTest is Test {
  address public constant RETRY_USER = address(123);
  address public constant SOLVE_EMERGENCY_USER = address(1234);
  address public constant CROSS_CHAIN_CONTROLLER = address(12345);

  address public constant BGD_GUARDIAN = address(1956);
  address public constant AAVE_GUARDIAN = address(1238975);
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  GranularGuardianAccessControl public control;

  function setUp() public {
    control = new GranularGuardianAccessControl(
      AAVE_GUARDIAN,
      RETRY_USER,
      SOLVE_EMERGENCY_USER,
      CROSS_CHAIN_CONTROLLER
    );
  }

  function test_initialization() public {
    assertEq(control.CROSS_CHAIN_CONTROLLER(), CROSS_CHAIN_CONTROLLER);
    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, AAVE_GUARDIAN), true);
    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), RETRY_USER);
    assertEq(control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0), SOLVE_EMERGENCY_USER);
  }

  function test_retryTx() public {
    vm.startPrank(RETRY_USER);
    _retryTx();
    vm.stopPrank();
  }

  function test_retryTxWhenWrongCaller() public {
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );
    _retryTx();
  }

  function test_retryEnvelope(bytes32 mockEnvId) public {
    vm.startPrank(RETRY_USER);
    //    bytes32 mockEnvId = keccak256(abi.encode('mock envelope id'));
    bytes32 envId = _retryEnvelope(mockEnvId);
    assertEq(envId, mockEnvId);
    vm.stopPrank();
  }

  function test_retryEnvelopeWhenWrongCaller(bytes32 mockEnvId) public {
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(address(this)),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );
    _retryEnvelope(mockEnvId);
  }

  function test_solveEmergency() public {
    vm.startPrank(SOLVE_EMERGENCY_USER);
    _solveEmergency();
    vm.stopPrank();
  }

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
    _solveEmergency();
  }

  function test_updateGuardian(address newGuardian) public {
    vm.startPrank(AAVE_GUARDIAN);
    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(IWithGuardian.updateGuardian.selector, newGuardian),
      abi.encode()
    );
    control.updateGuardian(newGuardian);
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

  function _solveEmergency() public {
    ICrossChainReceiver.ConfirmationInput[]
      memory newConfirmations = new ICrossChainReceiver.ConfirmationInput[](0);
    ICrossChainReceiver.ValidityTimestampInput[]
      memory newValidityTimestamp = new ICrossChainReceiver.ValidityTimestampInput[](0);
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToAllow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        0
      );
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverBridgeAdaptersToDisallow = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        0
      );
    address[] memory sendersToApprove = new address[](0);
    address[] memory sendersToRemove = new address[](0);
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarderBridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        0
      );
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarderBridgeAdaptersToDisable = new ICrossChainForwarder.BridgeAdapterToDisable[](
        0
      );

    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(
        ICrossChainControllerWithEmergencyMode.solveEmergency.selector,
        newConfirmations,
        newValidityTimestamp,
        receiverBridgeAdaptersToAllow,
        receiverBridgeAdaptersToDisallow,
        sendersToApprove,
        sendersToRemove,
        forwarderBridgeAdaptersToEnable,
        forwarderBridgeAdaptersToDisable
      ),
      abi.encode()
    );
    return
      control.solveEmergency(
        newConfirmations,
        newValidityTimestamp,
        receiverBridgeAdaptersToAllow,
        receiverBridgeAdaptersToDisallow,
        sendersToApprove,
        sendersToRemove,
        forwarderBridgeAdaptersToEnable,
        forwarderBridgeAdaptersToDisable
      );
  }

  function _retryEnvelope(bytes32 mockEnvId) internal returns (bytes32) {
    Envelope memory envelope = Envelope({
      nonce: 1,
      origin: address(12468),
      destination: address(2341),
      originChainId: 1,
      destinationChainId: 137,
      message: abi.encode('mock message')
    });
    uint256 gasLimit = 300_000;

    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(ICrossChainForwarder.retryEnvelope.selector, envelope, gasLimit),
      abi.encode(mockEnvId)
    );
    return control.retryEnvelope(envelope, gasLimit);
  }

  function _retryTx() internal {
    bytes memory encodedTransaction = abi.encode('some mock tx');
    uint256 gasLimit = 300_000;
    address[] memory bridgeAdaptersToRetry = new address[](0);

    vm.mockCall(
      CROSS_CHAIN_CONTROLLER,
      abi.encodeWithSelector(
        ICrossChainForwarder.retryTransaction.selector,
        encodedTransaction,
        gasLimit,
        bridgeAdaptersToRetry
      ),
      abi.encode()
    );
    control.retryTransaction(encodedTransaction, gasLimit, bridgeAdaptersToRetry);
  }
}
