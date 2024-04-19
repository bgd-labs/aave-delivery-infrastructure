//// SPDX-License-Identifier: BUSL-1.1
//pragma solidity ^0.8.0;
//import {TestUtils} from '../utils/TestUtils.sol';
//import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
//import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
//import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
//import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
//import '../BaseTest.sol';
//
//contract GranularGuardianAccessControlIntTest is BaseTest {
//  address public constant RETRY_USER = address(123);
//  address public constant SOLVE_EMERGENCY_USER = address(1234);
//  address public constant BGD_GUARDIAN = 0xbCEB4f363f2666E2E8E430806F37e97C405c130b;
//  address public constant AAVE_GUARDIAN = MiscPolygon.PROTOCOL_GUARDIAN;
//  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
//  // list of supported chains
//  uint256 destinationChainId = ChainIds.ETHEREUM;
//  GranularGuardianAccessControl public control;
//
//  function setUp() public {
//    vm.createSelectFork('polygon', 51416198);
//    control = new GranularGuardianAccessControl(
//      AAVE_GUARDIAN,
//      RETRY_USER,
//      SOLVE_EMERGENCY_USER,
//      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER
//    );
//    hoax(BGD_GUARDIAN);
//    OwnableWithGuardian(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER).updateGuardian(
//      address(control)
//    );
//  }
//
//  function test_initialization() public {
//    assertEq(control.CROSS_CHAIN_CONTROLLER(), GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER);
//    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, AAVE_GUARDIAN), true);
//    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
//    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
//    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
//    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
//    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), RETRY_USER);
//    assertEq(control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0), SOLVE_EMERGENCY_USER);
//  }
//
//  function test_retryTx(
//    address destination,
//    uint256 gasLimit
//  )
//    public
//    generateRetryTxState(
//      GovernanceV3Polygon.EXECUTOR_LVL_1,
//      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
//      destinationChainId,
//      destination,
//      gasLimit
//    )
//  {
//    vm.assume(gasLimit < 300_000);
//    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
//      TestParams({
//        destination: destination,
//        origin: address(this),
//        originChainId: block.chainid,
//        destinationChainId: destinationChainId,
//        envelopeNonce: ICrossChainForwarder(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//          .getCurrentTransactionNonce() - 1,
//        transactionNonce: ICrossChainForwarder(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//          .getCurrentTransactionNonce() - 1
//      })
//    );
//    ICrossChainForwarder.ChainIdBridgeConfig[] memory bridgeAdaptersByChain = ICrossChainForwarder(
//      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER
//    ).getForwarderBridgeAdaptersByChain(destinationChainId);
//    address[] memory bridgeAdaptersToRetry = new address[](1);
//    bridgeAdaptersToRetry[0] = bridgeAdaptersByChain[2].currentChainBridgeAdapter;
//    vm.startPrank(RETRY_USER);
//    control.retryTransaction(extendedTx.transactionEncoded, gasLimit, bridgeAdaptersToRetry);
//    vm.stopPrank();
//  }
//
//  function test_retryTxWhenWrongCaller() public {
//    uint256 gasLimit = 300_000;
//    address[] memory bridgeAdaptersToRetry = new address[](0);
//    vm.expectRevert(
//      bytes(
//        string.concat(
//          'AccessControl: account 0x',
//          TestUtils.toAsciiString(address(this)),
//          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
//        )
//      )
//    );
//    control.retryTransaction(abi.encode('will not get used'), gasLimit, bridgeAdaptersToRetry);
//  }
//
//  function test_retryEnvelope(
//    address destination,
//    uint256 gasLimit
//  )
//    public
//    generateRetryTxState(
//      GovernanceV3Polygon.EXECUTOR_LVL_1,
//      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
//      destinationChainId,
//      destination,
//      gasLimit
//    )
//  {
//    vm.assume(gasLimit < 300_000);
//    vm.startPrank(RETRY_USER);
//
//    uint256 txNonce = ICrossChainForwarder(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//      .getCurrentTransactionNonce() - 1;
//    uint256 envNonce = ICrossChainForwarder(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//      .getCurrentEnvelopeNonce() - 1;
//
//    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
//      TestParams({
//        destination: destination,
//        origin: address(this),
//        originChainId: block.chainid,
//        destinationChainId: destinationChainId,
//        envelopeNonce: envNonce,
//        transactionNonce: txNonce
//      })
//    );
//
//    bytes32 newTxId = control.retryEnvelope(extendedTx.envelope, gasLimit);
//    ExtendedTransaction memory extendedTxAfter = _generateExtendedTransaction(
//      TestParams({
//        destination: destination,
//        origin: address(this),
//        originChainId: block.chainid,
//        destinationChainId: destinationChainId,
//        envelopeNonce: envNonce,
//        transactionNonce: ICrossChainForwarder(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//          .getCurrentTransactionNonce() - 1
//      })
//    );
//
//    assertEq(extendedTxAfter.transactionId, newTxId);
//    vm.stopPrank();
//  }
//
//  function test_retryEnvelopeWhenWrongCaller(uint256 gasLimit) public {
//    Envelope memory envelope;
//    vm.expectRevert(
//      bytes(
//        string.concat(
//          'AccessControl: account 0x',
//          TestUtils.toAsciiString(address(this)),
//          ' is missing role 0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3'
//        )
//      )
//    );
//    control.retryEnvelope(envelope, gasLimit);
//  }
//
//  function test_solveEmergency()
//    public
//    generateEmergencyState(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//    validateEmergencySolved(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER)
//  {
//    vm.startPrank(SOLVE_EMERGENCY_USER);
//    control.solveEmergency(
//      new ICrossChainReceiver.ConfirmationInput[](0),
//      new ICrossChainReceiver.ValidityTimestampInput[](0),
//      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
//      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
//      new address[](0),
//      new address[](0),
//      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
//      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
//    );
//    vm.stopPrank();
//  }
//
//  function test_solveEmergencyWhenWrongCaller() public {
//    vm.expectRevert(
//      bytes(
//        string.concat(
//          'AccessControl: account 0x',
//          TestUtils.toAsciiString(address(this)),
//          ' is missing role 0xf4cdc679c22cbf47d6de8e836ce79ffdae51f38408dcde3f0645de7634fa607d'
//        )
//      )
//    );
//    control.solveEmergency(
//      new ICrossChainReceiver.ConfirmationInput[](0),
//      new ICrossChainReceiver.ValidityTimestampInput[](0),
//      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
//      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
//      new address[](0),
//      new address[](0),
//      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
//      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
//    );
//  }
//
//  function test_updateGuardian(address newGuardian) public {
//    vm.startPrank(AAVE_GUARDIAN);
//    control.updateGuardian(newGuardian);
//    assertEq(IWithGuardian(GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER).guardian(), newGuardian);
//    vm.stopPrank();
//  }
//
//  function test_updateGuardianWhenWrongCaller(address newGuardian) public {
//    vm.expectRevert(
//      bytes(
//        string.concat(
//          'AccessControl: account 0x',
//          TestUtils.toAsciiString(address(this)),
//          ' is missing role 0x0000000000000000000000000000000000000000000000000000000000000000'
//        )
//      )
//    );
//    control.updateGuardian(newGuardian);
//  }
//  //  function _retryEnvelope(bytes32 mockEnvId) internal returns (bytes32) {
//  //    Envelope memory envelope = Envelope({
//  //      nonce: 1,
//  //      origin: address(12468),
//  //      destination: address(2341),
//  //      originChainId: 1,
//  //      destinationChainId: 137,
//  //      message: abi.encode('mock message')
//  //    });
//  //    uint256 gasLimit = 300_000;
//  //
//  //    vm.mockCall(
//  //      GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
//  //      abi.encodeWithSelector(ICrossChainForwarder.retryEnvelope.selector, envelope, gasLimit),
//  //      abi.encode(mockEnvId)
//  //    );
//  //    return control.retryEnvelope(envelope, gasLimit);
//  //  }
//}
