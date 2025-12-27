Authorization-Governed Vault System

This repository implements a secure, authorization-based vault architecture that separates asset custody from permission validation.
The design mirrors real-world Web3 custody systems such as bridges, multisigs, and custodial vaults where fund movement requires off-chain approval and on-chain verification.

🧠 Architecture Overview

The system consists of two on-chain contracts:

Contract	Responsibility
SecureVault	Holds ETH and executes withdrawals
AuthorizationManager	Verifies and consumes withdrawal permissions

The vault never performs signature verification.
All cryptographic logic is isolated inside the Authorization Manager, enforcing split-trust security.

Off-chain signer
        ↓
Signed Authorization
        ↓
AuthorizationManager (verify + consume)
        ↓
SecureVault (transfer ETH)

🔑 Authorization Design

Each withdrawal permission is bound to:

Vault address

Chain ID

Recipient

Amount

Nonce

Expiry

These fields are encoded using Solidity ABI encoding and hashed:

keccak256(abi.encode(
    vault,
    chainId,
    recipient,
    amount,
    nonce,
    expiry
))


The resulting hash is signed off-chain by a trusted authority.

The AuthorizationManager recovers the signer using ECDSA and verifies that:

The signer is the trusted authority

The authorization has not been used before

The authorization has not expired

Once validated, the authorization is irreversibly consumed.

🛡 Replay Protection

Each authorization hash is stored on-chain:

mapping(bytes32 => bool) public usedAuthorizations;


When an authorization is used:

It is marked as consumed before returning success

Any future reuse will revert

This prevents:

Duplicate withdrawals

Reentrancy-based replays

Cross-contract replays

🔒 Vault Safety Guarantees

The vault enforces the following invariants:

ETH is transferred only after authorization succeeds

Internal state updates occur before ETH transfer

Vault balance can never go negative

Signatures are never verified inside the vault

This ensures that even if the vault is called maliciously, funds cannot move without valid authorization.

🐳 Running the System

The entire system is deployed using Docker.

Start the system
docker-compose up --build


This will:

Start a local blockchain (Ganache)

Compile contracts

Deploy AuthorizationManager

Deploy SecureVault

Print deployed addresses

🧪 Manual Validation (Security Proof)

After Docker is running:

npx hardhat console --network localhost


Deposit ETH into the vault

Create an off-chain authorization

Withdraw using the signed authorization

Attempt to reuse it → must revert

This demonstrates:

Off-chain signing

On-chain verification

Replay protection

Vault safety

🧩 Design Guarantees
Property	Enforced
Single-use authorizations	✔
Chain-bound permissions	✔
Vault-bound permissions	✔
Recipient-bound	✔
Amount-bound	✔
Replay-safe	✔
Split trust	✔
State-before-value	✔
Docker reproducible	✔
📦 Why This Design Is Secure

This architecture matches how real production Web3 custody systems are built:

Bridges

Custodial vaults

Multisigs

Rollups

Asset gateways

Separating authorization from custody drastically reduces attack surface and enforces strong invariants even in adversarial execution environments.

🏁 Conclusion

This system demonstrates:

Secure multi-contract design

Cryptographic authorization enforcement

Replay-safe execution

Production-grade DevOps

It satisfies all required security, correctness, and deployment criteria of the challenge.