// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ERC20 (Standalone Minimal Implementation)
 * @notice Minimal ERC20 implementation for benchmarking and control-set testing.
 * @dev Self-contained, no imports, Solidity ^0.8.20 (built-in overflow checks).
 */
contract ERC20 {

    // Token metadata
    string public name;
    string public symbol;
    uint8 public immutable decimals = 18;

    // Supply
    uint256 private _totalSupply;

    // State mappings
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        _mint(msg.sender, initialSupply);
    }

    // =======================
    // View functions
    // =======================

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // =======================
    // Core ERC20 logic
    // =======================

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");

        _approve(from, msg.sender, currentAllowance - amount);
        _transfer(from, to, amount);

        return true;
    }

    // =======================
    // Internal logic
    // =======================

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: insufficient balance");

        unchecked {
            _balances[from] = senderBalance - amount;
        }

        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(spender != address(0), "ERC20: approve to zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }
}
