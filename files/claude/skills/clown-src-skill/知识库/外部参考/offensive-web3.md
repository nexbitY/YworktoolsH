---
name: offensive-web3
description: "Web3 / smart-contract security auditing methodology for EVM, Move/Aptos, Solana, and TRON. Covers reentrancy variants (single-function, cross-function, cross-contract, read-only), access control (role bypass, initialization hijack, confused deputy, proxy admin), delegatecall/proxy pitfalls (uninitialized proxy, storage collision, selector clash), oracle manipulation (spot price, TWAP, stale price), flash-loan-funded attacks, MEV/front-running/sandwich, signature bugs (replay, EIP-712 domain, malleability), token-standard traps (approve race, fee-on-transfer, rebasing, rebase accounting), upgradeability, and Solana/Move chain-specific bugs (missing signer, account confusion, PDA, CPI, owner check, resource/ability misuse). Includes tooling (Slither, Mythril, Foundry, Echidna, Medusa, Halmos, Anchor, Move Prover) and the 4-gate finding-validation method. Use when auditing smart contracts or DeFi protocols, or hunting Web3 bounties on Immunefi / Code4rena / Sherlock."
---

# Web3 / Smart Contract — Offensive Testing Methodology

Smart-contract bugs are **permanent and adversarial**: there is no WAF, no patch window for deployed immutable code, and every function is callable by anyone with gas. The threat model is not "a user misbehaves" but "an attacker with unlimited capital, atomic composability, and mempool visibility extracts value".

## Quick Workflow

1. Map the protocol: assets, actors, trust boundaries, privileged roles, external dependencies (oracles, other protocols)
2. Build a call graph of state-changing entrypoints and who can reach them
3. For each entrypoint, ask the four DeFi questions: can I reenter, can I manipulate a price, can I flash-loan the prerequisite, can I front-run
4. Write a PoC in Foundry (`forge test`) — no PoC, no finding
5. Run the 4-gate validation before reporting

---

## Scope & Platforms

| Platform | Chains | Severity model |
|----------|--------|----------------|
| Immunefi | EVM, Solana, Move, others | Impact-based (Critical/High/Medium/Low), payout tiers by TVL at risk |
| Code4rena | EVM | High/Medium/QA, judged by wardens |
| Sherlock | EVM | High/Medium, contest-based |
| Cantina / HackenProof | EVM | Mixed |

**Severity anchor:** on Immunefi, "direct loss of funds" is usually Critical; "theft of unclaimed yield" is High; "griefing / temporary DoS" is Medium. Always tie the finding to a quantified loss.

---

## EVM Vulnerability Classes

### Reentrancy (four distinct variants)

| Variant | Mechanism | Classic example |
|---------|-----------|-----------------|
| Single-function | `withdraw()` updates balance *after* the external call | The DAO |
| Cross-function | Reenter a *different* function that shares state | `transfer()` during `withdraw()` |
| Cross-contract | Victim calls attacker contract that reenters victim | Lending pool + malicious token |
| Read-only | `view` function reads stale state mid-transaction | Balancer/Curve-style pool accounting |

```solidity
// VULNERABLE: state updated after external call
function withdraw(uint256 amt) external {
    require(balances[msg.sender] >= amt);
    (bool ok, ) = msg.sender.call{value: amt}("");   // attacker reenters here
    require(ok);
    balances[msg.sender] -= amt;                      // too late
}

// FIX: checks-effects-interactions + reentrancy guard
function withdraw(uint256 amt) external nonReentrant {
    require(balances[msg.sender] >= amt);
    balances[msg.sender] -= amt;                      // effect first
    (bool ok, ) = msg.sender.call{value: amt}("");
    require(ok);
}
```

**Also check:** ERC-777 / ERC-1155 `tokensReceived` hooks, `onERC721Received`, and any `call{value:}` to a user-supplied address are reentrancy vectors even when a guard exists on the *primary* function.

### Access Control

- **Role bypass** — `onlyOwner` applied to the wrong function, or a role granted in a constructor that can be re-granted.
- **Initialization hijack** — upgradeable contracts using `initialize()`: if it is not protected by `initializer` and not called atomically at deploy, an attacker front-runs and becomes owner.
- **Confused deputy** — a privileged contract performs an action on behalf of an unprivileged caller without validating the caller's intent.
- **Proxy admin abuse** — `upgradeTo` reachable by an address that should not have it; `TransparentUpgradeableProxy` admin-selector clash.

### Delegatecall / Proxy Pitfalls

- **Storage collision** — proxy and implementation storage layouts diverge (especially with inheritance order changes across upgrades).
- **Uninitialized implementation** — the logic contract behind a proxy is left uninitialized; attacker initializes it and calls `selfdestruct` / `delegatecall`.
- **Function selector clash** — a proxy's own function shares a 4-byte selector with an implementation function (e.g. `collate_propagate_storage` in the Parity wallet).
- **Delegatecall to user-controlled target** — arbitrary code execution in the caller's storage context.

### Arithmetic & Precision

- **Rounding direction** — rounding *down* on deposits and *up* on withdrawals favors the user; the inverse is exploitable. Check every `mulDiv` / share calculation.
- **Precision loss / first-depositor inflation** — an empty vault can be inflated (ERC-4626 donation attack): attacker mints 1 wei then donates a large amount to make the victim's shares round to zero.
- **Unchecked overflow** — only relevant in `unchecked {}` blocks or pre-0.8 Solidity.
- **Decimals mismatch** — combining an 18-decimal and a 6-decimal token without normalization.

### Oracle Manipulation

| Oracle type | Attack |
|-------------|--------|
| Spot price (`getReserves()`) | Flash-loan to skew the pool, read the skewed price in the same tx |
| AMM TWAP (short window) | Multi-block manipulation, still profitable if window < cost of capital |
| Chainlink `latestAnswer` | Stale round, `updatedAt` not checked, no min/max bounds, L2 sequencer-uptime feed ignored |
| Custom `getPrice()` | Return value not validated (`> 0`, freshness, decimals) |

**Rule:** a price that can be moved within a single transaction by an actor with no capital is not a price.

### Flash-Loan-Funded Attacks

Flash loans make any *capital requirement* free. For every finding ask: "if the attacker had infinite capital for one transaction, does this break?" Common patterns: governance vote with borrowed tokens, liquidation cascades, oracle skew, collateral-inflation.

### MEV — Front-running / Sandwich / Back-running

- **Sandwich** — see a large swap, buy before, sell after.
- **Front-run a state change** — e.g. front-run `setRewardRate` or an oracle update.
- **Back-run** — exploit the state a victim's tx leaves behind.
- **Commit-reveal bypass** — reveals are visible in mempool; check for missing commit phase.

### Signature Bugs

- **Replay** — no chainid/contract/address binding; same signature valid on a fork or a second contract.
- **EIP-712 domain** — `domainSeparator` missing `chainId` or `verifyingContract`, or not recomputed on fork.
- **Malleability** — accepting both `(v,r,s)` and `(v',r',s')` for the same message (ECDSA malleability) enabling replay of a "cancelled" signature.
- **`ecrecover` returning `address(0)`** — unchecked return on malformed input.
- **Nonce handling** — nonce reused across domains, or off-chain nonce not invalidated after use.

### Token-Standard Traps

- **ERC-20 `approve` race** — the classic allowance front-running; mitigated by `increaseAllowance`, but check integrators.
- **Fee-on-transfer / deflationary tokens** — code that assumes `received == sent` breaks.
- **Rebasing tokens** — balances change without transfers; share accounting breaks.
- **Non-standard return** — tokens returning no value (USDT) or `false` on failure; unchecked `transfer` return.
- **ERC-721/1155** — `safeTransferFrom` reentrancy via `onERC721Received`.

---

## Solana Vulnerability Classes

| Class | Description |
|-------|-------------|
| Missing signer check | `AccountInfo` used as authority without `is_signer` |
| Missing owner check | Account not validated against the expected program owner |
| Account confusion / type cosplay | Two accounts of different types share a discriminator |
| PDA substitution | Unchecked bump/seed lets attacker supply a different PDA |
| Arbitrary CPI | `invoke` target program not validated |
| Integer overflow | Rust release builds wrap unless `checked_*` is used |
| Closing accounts | Account closed but data not zeroed → revival |
| Sysvar spoofing | Sysvar account passed as a normal account |

```rust
// VULNERABLE: no signer check
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault;
    vault.balance -= amount;                 // anyone can call
    Ok(())
}

// FIX: require the authority to have signed
#[derive(Accounts)]
pub struct Withdraw<'info> {
    #[account(mut, has_one = authority)]
    pub vault: Account<'info, Vault>,
    pub authority: Signer<'info>,
}
```

---

## Move / Aptos Vulnerability Classes

- **Ability misuse** — a struct given `copy`/`drop` that represents a capability; `store` letting it leave its module.
- **Missing signer check** — a public entry function that mutates global state without `&signer`.
- **Capability leak** — `Capability`/`SignerCapability` stored in a public or copyable struct.
- **Resource double-spend** — logic that does not `move` the resource, allowing reuse.
- **Arithmetic** — Move aborts on overflow (safe), but precision/rounding bugs remain.

---

## TRON

EVM-compatible (TVM). Reuse the entire EVM section; additionally check TRC-20 vs ERC-20 differences, energy/bandwidth fee model, and TRON-specific `tx.origin`-style patterns.

---

## Tooling

| Tool | Use |
|------|-----|
| `slither .` | Static analysis, detector suite, inheritance graph |
| `myth analyze` | Symbolic execution for specific bug classes |
| `forge test --fork-url` | PoC against live forked state |
| `echidna-test` / `medusa` | Property-based fuzzing of invariants |
| `halmos` | Symbolic testing of Foundry tests |
| `anchor test` | Solana PoC harness |
| `move prover` | Formal verification of Move modules |
| `cargo audit` / `slither-check-upgradeability` | Dependency and upgrade safety |

**Invariant fuzzing is the highest-yield tool for DeFi:** write "the protocol's total assets must never decrease except via authorized withdrawal" and let Echidna/Medusa break it.

---

## The 4-Gate Finding Validation

Before a finding is real, all four gates must pass:

1. **Refutation** — can an existing guard (modifier, require, invariant) block the attack? Try to disprove your own finding first.
2. **Reachability** — can the vulnerable state actually exist in a live deployment (right roles, right parameters, right chain)?
3. **Trigger** — can an *unprivileged* actor execute it profitably (accounting for gas, slippage, flash-loan fees)?
4. **Impact** — is there material harm to an identifiable victim with a quantified loss?

Fail any gate → it is a *lead*, not a finding. Keep it in a lead ledger with states `OPEN → MUTATING → FINDING | PARKED | KILLED`.

---

## Reporting (Immunefi-oriented)

- Lead with **impact and quantified loss**, not the code smell.
- Include: affected contract + chain + address, vulnerable function, root cause, step-by-step attack, PoC (`forge test` output), recommended fix, severity rationale.
- Attach the PoC as a runnable test; judges reproduce it.
- Severity: map to the platform's impact matrix (e.g. "permanent freezing of funds" vs "theft of unclaimed yield").

---

## Key References

- Immunefi Vulnerability Severity Classification System
- SWC Registry (Smart Contract Weakness Classification)
- Consensys "Ethereum Smart Contract Best Practices"
- DeFiVulnLabs / Damn Vulnerable DeFi (practice targets)
- Solana: "Solana Program Security" checklist; Anchor security docs
- OWASP Smart Contract Top 10
