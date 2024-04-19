// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TestUtils} from '../utils/TestUtils.sol';
import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import '../BaseTest.sol';

contract GranularGuardianAccessControlTest is BaseTest {
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  GranularGuardianAccessControl public control;

  modifier setUpGranularGuardians(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) {
    _filterAddress(defaultAdmin);
    _filterAddress(retryGuardian);
    _filterAddress(solveEmergencyGuardian);
    _filterAddress(ccc);
    IGranularGuardianAccessControl.InitialGuardians
      memory initialGuardians = IGranularGuardianAccessControl.InitialGuardians({
        defaultAdmin: defaultAdmin,
        retryGuardian: retryGuardian,
        solveEmergencyGuardian: solveEmergencyGuardian
      });
    control = new GranularGuardianAccessControl(initialGuardians, ccc);
    _;
  }

  function setUp() public {}

  function test_initializationWithWrongDefaultAdmin(
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) public {
    _filterAddress(retryGuardian);
    _filterAddress(solveEmergencyGuardian);
    _filterAddress(ccc);
    IGranularGuardianAccessControl.InitialGuardians
      memory initialGuardians = IGranularGuardianAccessControl.InitialGuardians({
        defaultAdmin: address(0),
        retryGuardian: retryGuardian,
        solveEmergencyGuardian: solveEmergencyGuardian
      });
    vm.expectRevert(DefaultAdminCantBe0.selector);
    new GranularGuardianAccessControl(initialGuardians, ccc);
  }

  function test_initializationWithWrongCCC(
    address retryGuardian,
    address solveEmergencyGuardian,
    address defaultAdmin
  ) public {
    _filterAddress(defaultAdmin);
    _filterAddress(retryGuardian);
    _filterAddress(solveEmergencyGuardian);
    IGranularGuardianAccessControl.InitialGuardians
      memory initialGuardians = IGranularGuardianAccessControl.InitialGuardians({
        defaultAdmin: defaultAdmin,
        retryGuardian: retryGuardian,
        solveEmergencyGuardian: solveEmergencyGuardian
      });
    vm.expectRevert(CrossChainControllerCantBe0.selector);
    new GranularGuardianAccessControl(initialGuardians, address(0));
  }

  function test_initialization(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    assertEq(control.CROSS_CHAIN_CONTROLLER(), ccc);
    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, defaultAdmin), true);
    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), retryGuardian);
    assertEq(control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0), solveEmergencyGuardian);
  }

  function test_retryTx(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.startPrank(retryGuardian);
    _retryTx(ccc);
    vm.stopPrank();
  }

  function test_retryTxWhenWrongCaller(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    address retryCaller
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.assume(retryCaller != retryGuardian);
    hoax(retryCaller);
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(retryCaller),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );
    _retryTx(ccc);
  }

  function test_retryEnvelope(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    bytes32 mockEnvId
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.startPrank(retryGuardian);
    //    bytes32 mockEnvId = keccak256(abi.encode('mock envelope id'));
    bytes32 envId = _retryEnvelope(ccc, mockEnvId);
    assertEq(envId, mockEnvId);
    vm.stopPrank();
  }

  function test_retryEnvelopeWhenWrongCaller(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    address retryCaller,
    bytes32 mockEnvId
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.assume(retryCaller != retryGuardian);
    hoax(retryCaller);
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(retryCaller),
          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
        )
      )
    );
    _retryEnvelope(ccc, mockEnvId);
  }

  function test_solveEmergency(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.startPrank(solveEmergencyGuardian);
    _solveEmergency(ccc);
    vm.stopPrank();
  }

  function test_solveEmergencyWhenWrongCaller(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    address solveCaller
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.assume(solveCaller != solveEmergencyGuardian);
    hoax(solveCaller);
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(solveCaller),
          ' is missing role 0xf4cdc679c22cbf47d6de8e836ce79ffdae51f38408dcde3f0645de7634fa607d'
        )
      )
    );
    _solveEmergency(ccc);
  }

  function test_updateGuardian(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    address newGuardian
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.startPrank(defaultAdmin);
    vm.mockCall(
      ccc,
      abi.encodeWithSelector(IWithGuardian.updateGuardian.selector, newGuardian),
      abi.encode()
    );
    control.updateGuardian(newGuardian);
    vm.stopPrank();
  }

  function test_updateGuardianWhenWrongCaller(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc,
    address guardianCaller,
    address newGuardian
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.assume(guardianCaller != defaultAdmin);
    hoax(guardianCaller);
    vm.expectRevert(
      bytes(
        string.concat(
          'AccessControl: account 0x',
          TestUtils.toAsciiString(guardianCaller),
          ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
        )
      )
    );
    control.updateGuardian(newGuardian);
  }

  function test_updateGuardianWhenWrongAddress(
    address defaultAdmin,
    address retryGuardian,
    address solveEmergencyGuardian,
    address ccc
  ) public setUpGranularGuardians(defaultAdmin, retryGuardian, solveEmergencyGuardian, ccc) {
    vm.startPrank(defaultAdmin);
    vm.expectRevert(NewGuardianCantBe0.selector);
    control.updateGuardian(address(0));
    vm.stopPrank();
  }

  function _solveEmergency(address ccc) public {
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
      ccc,
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

  function _retryEnvelope(address ccc, bytes32 mockEnvId) internal returns (bytes32) {
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
      ccc,
      abi.encodeWithSelector(ICrossChainForwarder.retryEnvelope.selector, envelope, gasLimit),
      abi.encode(mockEnvId)
    );
    return control.retryEnvelope(envelope, gasLimit);
  }

  function _retryTx(address ccc) internal {
    bytes memory encodedTransaction = abi.encode('some mock tx');
    uint256 gasLimit = 300_000;
    address[] memory bridgeAdaptersToRetry = new address[](0);

    vm.mockCall(
      ccc,
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
