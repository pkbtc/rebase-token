# Rebase Token (RBT)

## Overview
Rebase Token (RBT) is an ERC-20 token with a dynamic balance mechanism based on interest accumulation. The token utilizes a rebase mechanism to adjust user balances over time, making it suitable for interest-bearing assets and inflationary/deflationary models.

## Features
- **Interest Accumulation:** Users' balances grow over time based on a set interest rate.
- **Minting and Burning:** Controlled via role-based access.
- **Role-Based Access Control (RBAC):** Uses OpenZeppelin's `AccessControl` to restrict minting and burning privileges.
- **Transfer with Interest Adjustment:** Ensures correct balance updates before transfers.
- **Rebase Mechanism:** Balances update dynamically without requiring user interaction.

## Smart Contract Details

### Contract Name: `RebaseToken.sol`

### Dependencies
- OpenZeppelin Contracts
  - `ERC20.sol`
  - `Ownable.sol`
  - `AccessControl.sol`

### Constructor
```solidity
constructor() ERC20("Rebase Token", "RBT") Ownable(msg.sender) {}
```
Initializes the token with:
- **Name:** Rebase Token
- **Symbol:** RBT
- **Owner:** The deployer

### Interest Rate Management
- `setInterestRate(uint256 _newInterestRate)`: Allows the owner to set a new interest rate (can only decrease).
- `getInterestRate()`: Returns the current interest rate.
- `getUserInterestRate(address _user)`: Retrieves the interest rate applicable to a specific user.

### Minting & Burning
- `grantMintAndBurnRole(address _account)`: Grants the `MINT_AND_BURN_ROLE` to an address.
- `mint(address _to, uint256 _value, uint256 _userInterestRate)`: Mints tokens while updating interest.
- `burn(address _from, uint256 _amount)`: Burns tokens while ensuring interest is accounted for.

### Transfers
- `transfer(address _recipient, uint256 _amount)`: Transfers tokens while adjusting balances for interest.
- `transferFrom(address _sender, address _recipient, uint256 _amount)`: Transfers on behalf of another address while handling interest.

### Rebase Calculation
- `balanceOf(address _user)`: Returns the dynamically updated balance with interest.
- `principalBalance(address _user)`: Returns the user's original balance without rebase effects.
- `_mintAccurateInterest(address _user)`: Updates a user’s balance to account for interest before transactions.

## Deployment
1. Install dependencies:
   ```sh
   npm install @openzeppelin/contracts
   ```
2. Compile the contract:
   ```sh
   forge build
   ```
3. Deploy using Foundry or Hardhat.

## Usage
- The contract is managed by an owner who can set the interest rate.
- Only addresses with `MINT_AND_BURN_ROLE` can mint and burn tokens.
- Balances increase over time based on the interest rate.

## Security Considerations
- **Access Control:** Only authorized addresses can mint/burn tokens.
- **Interest Updates:** Users' balances are updated dynamically without additional interactions.
- **Precision Handling:** Uses `PRESSION_FACTOR = 1e18` to prevent rounding errors.



## Author
Developed by [pketh]

