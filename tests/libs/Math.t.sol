// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Math} from '../../src/contracts/libs/Math.sol';

contract MathTest is Test {
  function setUp() public {}

  function test_randMod(uint256 modulus) public {
    modulus = bound(modulus, 1, 1000);

    uint256 randomNumber = Math.randMod(modulus);

    assertGe(randomNumber, 1);
    assertLe(randomNumber, 1000);
  }
}
