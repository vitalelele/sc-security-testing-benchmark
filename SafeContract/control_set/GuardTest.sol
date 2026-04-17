// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Se il file ReentrancyGuard.sol è nella stessa cartella
abstract contract ReentrancyGuard {
    uint256 private _status;
    constructor() { _status = 1; }
    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }
}

contract GuardTest is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
        
        balances[msg.sender] = 0;
    }
}
