// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Math} from '../../src/contracts/libs/Math.sol';

contract MathTest is Test {
  function setUp() public {}

  function test_randMod(uint256 modulus) public {
    modulus = bound(modulus, 1, 1000);

    uint256 randomNumber = Math.randMod(modulus);

    assertGe(randomNumber, 0);
    assertLe(randomNumber, 1000);
  }

  function test_arrayOfRandMod() public {
    //    modulus = bound(modulus, 1, 1000);
    //    amountOfRand = bound(amountOfRand, 2, 10);
    uint256 modulus = 6;
    uint256 amountOfRand = 5;

    for (uint256 i = 0; i < amountOfRand; i++) {
      uint256 randomNumber = Math.randMod(modulus);
      console.log('rand', randomNumber);
      assertGe(randomNumber, 0);
      assertLe(randomNumber, 1000);
    }
  }
}
