// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

contract BaseAdapterTest is Test {
  function _assumeSafeAddress(address addressToFilter) internal pure {
    vm.assume(
      addressToFilter != address(0) &&
        addressToFilter != 0xCe71065D4017F316EC606Fe4422e11eB2c47c246 && // FuzzerDict
        addressToFilter != 0x4e59b44847b379578588920cA78FbF26c0B4956C && // CREATE2 Factory (?)
        addressToFilter != 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84 && // address(this)
        addressToFilter != 0x185a4dc360CE69bDCceE33b3784B0282f7961aea && // ???
        addressToFilter != 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D // cheat codes
    );
  }
}
