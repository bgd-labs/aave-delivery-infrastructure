// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Utils} from '../../src/contracts/libs/Utils.sol';

contract MathTest is Test {
  function setUp() public {}

  function test_randMod(uint256 entropy1, uint256 entropy2) public {
    vm.assume(entropy1 != entropy2);

    uint256 randomNumber1 = Utils.getPseudoRandom(entropy1);
    uint256 randomNumber2 = Utils.getPseudoRandom(entropy2);

    assertEq(randomNumber1 != randomNumber2, true);
  }
}
