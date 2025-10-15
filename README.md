# PerformanceTracker-Smart-Contract
# 🧩 PerformanceTracker Smart Contract

A lightweight Solidity smart contract that records **user performance data** — no imports, no constructors, and no input parameters.  
Each user can track their own attempts, successes, failures, session durations, and submitted scores directly on-chain.

---

## ⚙️ Features

- 🚫 **No imports or constructors**
- 🧍 Tracks each user (`msg.sender`) individually
- ⏱️ Record attempts, successes, failures, and timed sessions
- 💰 Submit scores using `msg.value` (no parameters)
- 📊 View personal performance summary via read functions
- 🔒 Fully decentralized — no admin or ownership logic

---

## 🪙 Contract Details

**Network:** Ethereum-compatible (EVM)  
**Language:** Solidity ^0.8.19  
**Deployed / Example Owner:** `0x5364789ab7752EC171B1aF21dB060a14B7d7A161`  

---

## 🧠 Main Functions

| Function | Type | Description |
|-----------|------|-------------|
| `recordAttempt()` | Transaction | Records one attempt |
| `recordSuccess()` | Transaction | Records a successful attempt |
| `recordFailure()` | Transaction | Records a failed attempt |
| `startSession()` | Transaction | Starts a timed session |
| `endSession()` | Transaction | Ends session and logs duration |
| `submitScore()` | Payable | Submits a numeric score (via `msg.value`) |
| `getMySummary()` | View | Returns all your performance data |
| `myAverageSubmittedScore()` | View | Returns average score |

---

## 📄 Example Usage (Remix IDE)

1. Open [Remix IDE](https://remix.ethereum.org)  
2. Paste the Solidity code into a new file  
3. Compile with **Solidity 0.8.19**  
4. Deploy to any EVM-compatible network (e.g., Sepolia, Polygon testnet)  
5. Use the UI to call functions directly (no inputs needed)  

---

## 📬 Author

**Address:** `0x5364789ab7752EC171B1aF21dB060a14B7d7A161`  
**License:** MIT  

---

> *A minimalistic, gas-efficient smart contract for on-chain performance tracking.*
