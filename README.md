# 🪙 Zero Stablecoin Protocol

A decentralized, algorithmic stablecoin system pegged 1:1 to USD, backed by exogenous collateral (wETH & wBTC) with a liquidation mechanism to maintain stability.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Smart Contracts](#smart-contracts)
- [Testing](#testing)
- [Security Considerations](#security-considerations)
- [License](#license)

## 🎯 Overview

**Zero** is a decentralized stablecoin protocol inspired by MakerDAO's DAI architecture with key features:
- **Exogenously Collateralized**: Backed by wETH and wBTC
- **Algorithmic Stability**: Maintains peg through over-collateralization
- **Decentralized**: No governance, fully algorithmic
- **Pegged to USD**: 1 ZERO = $1 USD

The system ensures stability through a **minimum 200% collateralization ratio** and automated liquidation mechanisms.

## ✨ Features

### Core Functionality
- ✅ **Mint ZERO**: Deposit collateral and mint stablecoins
- ✅ **Burn ZERO**: Burn tokens to reclaim collateral
- ✅ **Deposit Collateral**: Add wETH or wBTC as backing
- ✅ **Redeem Collateral**: Withdraw your collateral
- ✅ **Liquidation System**: Incentivized liquidation of undercollateralized positions
- ✅ **Health Factor Monitoring**: Real-time position health tracking

### Price Feeds
- Chainlink oracle integration for reliable price data
- Support for multiple collateral types
- Accurate USD value calculations

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              Zero Token                     │
│           (ERC20 Stablecoin)                │
└─────────────────────────────────────────────┘
                     ▲
                     │
                     │ Mints/Burns
                     │
┌─────────────────────────────────────────────┐
│              ZeroEngine                     │
│  ┌────────────────────────────────────┐    │
│  │  • Collateral Management           │    │
│  │  • Minting/Burning Logic           │    │
│  │  • Health Factor Calculations      │    │
│  │  • Liquidation Engine              │    │
│  └────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
          ▲                    ▲
          │                    │
   Chainlink Oracles    wETH & wBTC
```

### Key Components

**Zero Token**
- ERC20 token implementation
- Burnable functionality
- Ownable (by ZeroEngine only)

**ZeroEngine**
- Manages all protocol logic
- Handles collateral deposits/withdrawals
- Mints/burns ZERO tokens
- Calculates health factors
- Executes liquidations

## 🚀 Getting Started

### Prerequisites

```bash
- Foundry
- Git
- Node.js (optional, for scripts)
```

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd zero-stablecoin

# Install dependencies
forge install

# Build contracts
forge build
```

### Environment Setup

Create a `.env` file:

```env
SEPOLIA_RPC_URL=your_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_key
```

## 💻 Usage

### Deploying

```bash
forge script script/DeployZero.s.sol:DeployZero --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### Interacting with the Protocol

#### Deposit Collateral and Mint ZERO

```solidity
// Approve collateral
IERC20(weth).approve(address(zeroEngine), collateralAmount);

// Deposit and mint in one transaction
zeroEngine.depositCollateralAndMintZero(
    wethAddress,
    collateralAmount,
    amountZeroToMint
);
```

#### Check Health Factor

```solidity
uint256 healthFactor = zeroEngine.getHealthFactor(userAddress);
// healthFactor must be > 1e18 (i.e., > 1)
```

#### Liquidate Undercollateralized Position

```solidity
zeroEngine.liquidate(
    collateralAddress,
    userToLiquidate,
    debtToCover
);
```

## 📚 Smart Contracts

### ZeroEngine.sol

**Main Functions:**

- `depositCollateralAndMintZero()` - Deposit collateral and mint ZERO in one transaction
- `redeemCollateralForZero()` - Burn ZERO and redeem collateral
- `liquidate()` - Liquidate undercollateralized positions (earn 10% bonus)
- `getHealthFactor()` - Check position health
- `getAccountInformation()` - Get user's collateral and debt info

**Key Parameters:**
- Minimum Health Factor: 1e18 (200% collateralization)
- Liquidation Bonus: 10%
- Liquidation Precision: 100
- Liquidation Threshold: 50%

### Zero.sol

Standard ERC20 with:
- Burn functionality
- Owner-controlled minting (only ZeroEngine)

## 🧪 Testing

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testLiquidation

# Run fork tests
forge test --fork-url $SEPOLIA_RPC_URL

# Coverage
forge coverage
```

### Test Coverage

- ✅ Unit tests for all core functions
- ✅ Fuzz testing for edge cases
- ✅ Integration tests
- ✅ Liquidation scenarios
- ✅ Health factor calculations
- ✅ Oracle failure handling

## 🔒 Security Considerations

### Known Issues & Mitigations

1. **Oracle Dependency**: Relies on Chainlink price feeds
   - *Mitigation*: Heartbeat checks, staleness checks

2. **Liquidation Risk**: Users must maintain health factor > 1
   - *Mitigation*: Clear documentation, UI warnings

3. **Collateral Volatility**: Price crashes can cause cascading liquidations
   - *Mitigation*: 200% collateralization requirement, liquidation incentives

### Audit Status

⚠️ **This code is for educational purposes and has not been audited.** Do not use in production without a professional security audit.

## 🎓 Educational Purpose

This project demonstrates the implementation of a decentralized stablecoin protocol with algorithmic stability mechanisms, collateral management, and liquidation systems.

## 📄 License

MIT License - see LICENSE file for details

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

For questions or issues, please open an issue on GitHub.

---

**Built with ❤️ using Foundry**