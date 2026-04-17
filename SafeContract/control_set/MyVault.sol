// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SafeControlVault
/// @notice Minimal Ether vault designed as a "control" contract for security tool benchmarking.
///         Goals: (i) no known issues in reentrancy/arithmetic/access-control categories,
///         (ii) minimal surface, (iii) explicit best-practice patterns.
/// @dev - Uses Solidity >=0.8.x (checked arithmetic by default).
///      - Uses Check-Effects-Interactions (CEI) + a local nonReentrant guard.
///      - No admin/owner functions to avoid introducing access-control surfaces.
///      - No tx.origin, no delegatecall, no untrusted external calls except the final ETH transfer.
contract SafeControlVault {

    // Custom errors (cheaper than strings)
    error ZeroValue();
    error ZeroAmount();
    error InsufficientBalance(uint256 available, uint256 required);
    error TransferFailed();
    error Reentrancy();

    // State
    mapping(address => uint256) private _balanceOf;

    // Simple reentrancy lock: 0 = unlocked, 1 = locked
    uint256 private _lock;

    // Events
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, address indexed to, uint256 amount);

    // Modifiers
    modifier nonReentrant() {
        if (_lock == 1) revert Reentrancy();
        _lock = 1;
        _;
        _lock = 0;
    }

    // Deposit

    /// @notice Deposit ETH into the vault; credits msg.sender balance.
    function deposit() external payable {
        if (msg.value == 0) revert ZeroValue();
        // Effects
        _balanceOf[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Allow plain ETH transfers to behave like deposit().
    receive() external payable {
        if (msg.value == 0) revert ZeroValue();
        _balanceOf[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // Withdraw

    /// @notice Withdraw `amount` ETH to msg.sender.
    function withdraw(uint256 amount) external nonReentrant {
        _withdrawTo(msg.sender, amount);
    }

    /// @notice Withdraw `amount` ETH to a specified recipient address.
    /// @dev Kept explicit to test tooling behavior on address parameters while remaining safe.
    function withdrawTo(address to, uint256 amount) external nonReentrant {
        // No access-control needed: you can only withdraw your own credited balance.
        _withdrawTo(to, amount);
    }

    function _withdrawTo(address to, uint256 amount) private {
        if (amount == 0) revert ZeroAmount();

        uint256 bal = _balanceOf[msg.sender];
        if (bal < amount) revert InsufficientBalance(bal, amount);

        // Effects (CEI): update state BEFORE interaction
        unchecked {
            // unchecked is safe here because bal >= amount has been validated
            _balanceOf[msg.sender] = bal - amount;
        }

        // Interaction: transfer ETH using call (robust to gas changes)
        (bool ok, ) = to.call{value: amount}("");
        if (!ok) {
            // Rollback on failure to preserve user funds (atomicity)
            _balanceOf[msg.sender] = bal;
            revert TransferFailed();
        }

        emit Withdrawn(msg.sender, to, amount);
    }

    // Views

    /// @notice Returns the credited vault balance for `account`.
    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf[account];
    }

    /// @notice Returns the total ETH held by this vault.
    function totalHeld() external view returns (uint256) {
        return address(this).balance;
    }
}
