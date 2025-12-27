// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);
}

contract SecureVault {
    IAuthorizationManager public immutable authManager;

    uint256 public totalWithdrawn;

    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);

    constructor(address _authManager) {
        require(_authManager != address(0), "Invalid auth manager");
        authManager = IAuthorizationManager(_authManager);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bytes calldata signature
    ) external {
        require(address(this).balance >= amount, "Insufficient vault balance");

        bool ok = authManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            nonce,
            expiry,
            signature
        );

        require(ok, "Authorization failed");

        // State update BEFORE value transfer
        totalWithdrawn += amount;

        (bool sent, ) = recipient.call{value: amount}("");
        require(sent, "ETH transfer failed");

        emit Withdrawal(recipient, amount);
    }
}