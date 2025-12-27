// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AuthorizationManager {
    using ECDSA for bytes32;

    // The off-chain authority that signs withdrawal permissions
    address public immutable authority;

    // Tracks whether an authorization hash has been used
    mapping(bytes32 => bool) public usedAuthorizations;

    event AuthorizationConsumed(
        bytes32 indexed authId,
        address indexed vault,
        address indexed recipient,
        uint256 amount
    );

    constructor(address _authority) {
        require(_authority != address(0), "Invalid authority");
        authority = _authority;
    }

    /**
     * @notice Verifies and consumes a withdrawal authorization
     * @dev Can only be called by a vault contract
     */
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool) {
        require(block.timestamp <= expiry, "Authorization expired");

        // Construct deterministic message
        bytes32 message = keccak256(
            abi.encode(
                vault,
                block.chainid,
                recipient,
                amount,
                nonce,
                expiry
            )
        );

        bytes32 authId = MessageHashUtils.toEthSignedMessageHash(message);

        // Prevent replay
        require(!usedAuthorizations[authId], "Authorization already used");

        // Verify signature
        address recovered = authId.recover(signature);
        require(recovered == authority, "Invalid signature");

        // Mark as used BEFORE returning
        usedAuthorizations[authId] = true;

        emit AuthorizationConsumed(authId, vault, recipient, amount);
        return true;
    }
}
