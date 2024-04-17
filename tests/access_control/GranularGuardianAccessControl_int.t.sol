// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {TestUtils} from '../utils/TestUtils.sol';
import '../../src/contracts/access_control/GranularGuardianAccessControl.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import '../BaseTest.sol';

contract GranularGuardianAccessControlIntTest is BaseTest {
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  // list of supported chains
  uint256 destinationChainId = ChainIds.ETHEREUM;

  GranularGuardianAccessControl public control;
  address public ccc;

  modifier createGGAC(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle,
    bool withEmergency
  ) {
    vm.assume(retryUser != address(this));
    _filterAddress(clEmergencyOracle);
    _filterAddress(owner);
    _filterAddress(guardian);
    _filterAddress(retryUser);
    _filterAddress(solveEmergencyUser);

    // deploy ccc
    ccc = deployCCC(clEmergencyOracle, withEmergency, owner, destinationChainId);

    control = new GranularGuardianAccessControl(guardian, retryUser, solveEmergencyUser, ccc);

    OwnableWithGuardian(ccc).updateGuardian(address(control));
    _;
  }

  function setUp() public {}

  function test_initialization(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle,
    bool withEmergency
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, withEmergency)
  {
    assertEq(control.CROSS_CHAIN_CONTROLLER(), ccc);
    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, guardian), true);
    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), retryUser);
    assertEq(control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0), solveEmergencyUser);
  }

  function test_retryTx(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, true)
    generateRetryTxState(owner, ccc, destinationChainId, address(1324), 150_000)
  {
    _retryTx(retryUser);
  }

  function test_retryTxWhenWrongCaller(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle,
    bool withEmergency
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, withEmergency)
  {
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

    control.retryTransaction(abi.encode('will not get used'), 150_000, bridgeAdaptersToRetry);
  }

  function test_retryEnvelope(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, true)
    generateRetryTxState(owner, ccc, destinationChainId, address(1324), 150_000)
  {
    _retryEnvelope(retryUser);
  }

  function test_retryEnvelopeWhenWrongCaller(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle
  ) public createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, true) {
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
    control.retryEnvelope(envelope, 150_000);
  }

  function test_solveEmergency(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, true)
    generateEmergencyState(ccc)
    validateEmergencySolved(ccc)
  {
    vm.startPrank(solveEmergencyUser);
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
    vm.stopPrank();
  }

  function test_solveEmergencyWhenWrongCaller(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle
  ) public createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, true) {
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

  function test_updateGuardian(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle,
    bool withEmergency,
    address newGuardian
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, withEmergency)
  {
    _filterAddress(newGuardian);
    vm.startPrank(guardian);
    control.updateGuardian(newGuardian);
    assertEq(IWithGuardian(ccc).guardian(), newGuardian);
    vm.stopPrank();
  }

  function test_updateGuardianWhenWrongCaller(
    address owner,
    address guardian,
    address retryUser,
    address solveEmergencyUser,
    address clEmergencyOracle,
    bool withEmergency,
    address newGuardian
  )
    public
    createGGAC(owner, guardian, retryUser, solveEmergencyUser, clEmergencyOracle, withEmergency)
  {
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

  function _retryEnvelope(address retryUser) internal {
    vm.startPrank(retryUser);

    uint256 txNonce = ICrossChainForwarder(ccc).getCurrentTransactionNonce() - 1;
    uint256 envNonce = ICrossChainForwarder(ccc).getCurrentEnvelopeNonce() - 1;

    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: address(1324),
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envNonce,
        transactionNonce: txNonce
      })
    );

    bytes32 newTxId = control.retryEnvelope(extendedTx.envelope, 150_000);

    ExtendedTransaction memory extendedTxAfter = _generateExtendedTransaction(
      TestParams({
        destination: address(1324),
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: envNonce,
        transactionNonce: ICrossChainForwarder(ccc).getCurrentTransactionNonce() - 1
      })
    );

    assertEq(extendedTxAfter.transactionId, newTxId);
    vm.stopPrank();
  }

  function _retryTx(address retryUser) internal {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: address(1324),
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: destinationChainId,
        envelopeNonce: ICrossChainForwarder(ccc).getCurrentTransactionNonce() - 1,
        transactionNonce: ICrossChainForwarder(ccc).getCurrentTransactionNonce() - 1
      })
    );

    ICrossChainForwarder.ChainIdBridgeConfig[] memory bridgeAdaptersByChain = ICrossChainForwarder(
      ccc
    ).getForwarderBridgeAdaptersByChain(1);
    address[] memory bridgeAdaptersToRetry = new address[](1);
    bridgeAdaptersToRetry[0] = bridgeAdaptersByChain[1].currentChainBridgeAdapter;

    vm.startPrank(retryUser);
    control.retryTransaction(extendedTx.transactionEncoded, 150_000, bridgeAdaptersToRetry);
    vm.stopPrank();
  }
}
