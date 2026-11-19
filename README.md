# AgentCheckin

Daily check-in + streak + leaderboard dApp for Binance Agent ID holders, built for the [Binance Agent ID Hackathon](https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf).

## What it is

AgentCheckin lets Agent ID holders check in once a day, build a consecutive-day streak, and compete on a leaderboard. It is the simplest possible on-chain habit tracker — one function, one event, no fees, no admin.

## How Agent ID is used

Only addresses holding a SPACE ID Agent ID (ERC-721, non-transferable) can check in. The contract verifies holder status **on-chain** on every call by reading `balanceOf(msg.sender)` from the Agent ID registry:

- Registry (BNB Chain): [`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`](https://bscscan.com/address/0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F)

Non-holders revert with `"Not an Agent ID holder"`. No off-chain allowlist, no signatures — the registry is the source of truth.

## How it works

- `checkIn()` — check in once per UTC day. If your last check-in was yesterday, your streak grows by 1; any missed day resets it to 1. Emits `CheckIn(user, day, streak)`.
- `getStreak(address)`, `getTotalCheckins(address)`, `getLastCheckinDay(address)` — read a user's streak, total check-ins, and last check-in day.
- `totalCheckinsAll()` — total check-ins across all users.
- The leaderboard in the frontend is built from `CheckIn` events: unique check-in addresses are ranked by `totalCheckins`.

## How to use

1. Open `index.html` (no build step — it loads ethers.js from a CDN).
2. Connect your wallet (MetaMask / Binance Wallet) and switch to **BNB Chain (56)**.
3. If you hold an Agent ID, press **Check In Today**. Come back tomorrow to keep your streak alive.

## Contract

| Item | Value |
| --- | --- |
| Network | BNB Chain (56) |
| Contract address | **TBD** — not deployed yet |
| Agent ID registry | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` |

## Tech stack

- **Smart contract:** Solidity `^0.8.20`, no external dependencies (only the `IERC721` interface for the registry). No owner, no admin, no fees, no pausing.
- **Tests:** Foundry (`forge test`). 7 tests with a mock Agent ID registry: non-holder revert, first check-in, consecutive-day streak, same-day double check-in revert, gap-day streak reset, totals across users, event emission.
- **Frontend:** single `index.html`, ethers.js v5 via CDN, no build step.

## Development

```bash
# compile
forge build

# run tests (with gas report)
forge test --gas-report

# deploy (BSC mainnet) — NOT run yet
forge script script/Deploy.s.sol --rpc-url <bsc-rpc> --private-key <key> --broadcast
```

## License

MIT
