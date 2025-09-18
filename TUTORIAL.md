# Hello FHEVM: Your First Encrypted dApp Tutorial

Welcome to the ultimate beginner's guide to building privacy-preserving applications with FHEVM (Fully Homomorphic Encryption Virtual Machine)! This tutorial will walk you through creating your first encrypted dApp - a charity donation platform where donation amounts and donor preferences remain completely private.

## 🎯 What You'll Learn

By the end of this tutorial, you will:
- Understand what FHEVM and Fully Homomorphic Encryption (FHE) are
- Know how to set up an FHEVM development environment
- Build a smart contract that uses encrypted data
- Create a frontend that encrypts user inputs
- Deploy and interact with your encrypted dApp

## 📋 Prerequisites

You should be comfortable with:
- Basic Solidity programming (writing simple smart contracts)
- JavaScript fundamentals
- Using MetaMask wallet
- Basic command line operations

**No advanced math or cryptography knowledge required!**

## 🔧 What is FHEVM?

FHEVM (Fully Homomorphic Encryption Virtual Machine) is a revolutionary blockchain technology that allows smart contracts to perform computations on encrypted data without ever decrypting it. This means:

- **Private by Design**: Your sensitive data never appears in plain text on the blockchain
- **Computational Privacy**: Smart contracts can add, subtract, and compare encrypted values
- **End-to-End Encryption**: Data is encrypted on the client, stays encrypted on-chain, and can only be decrypted by authorized parties

## 🏗️ Project Overview

We're building an encrypted charity donation platform with these privacy features:

1. **Encrypted Donation Amounts**: The amount you donate is encrypted using FHE
2. **Private Anonymity Preferences**: Whether you want to donate anonymously is also encrypted
3. **Confidential Computations**: Total donations are calculated without revealing individual amounts
4. **Selective Disclosure**: Only authorized parties (like project beneficiaries) can decrypt relevant data

## 🛠️ Setup Instructions

### Step 1: Clone and Setup the Project

```bash
# Clone this repository
git clone <repository-url>
cd hello-fhevm-charity-dapp

# Install dependencies for smart contract development
npm install

# Copy environment variables
cp .env.example .env
# Edit .env with your private key if deploying to testnet
```

### Step 2: Understanding the Project Structure

```
hello-fhevm-charity-dapp/
├── contracts/
│   └── CharityDonationPlatform.sol    # FHEVM smart contract
├── deploy/
│   └── 01-deploy-charity.js           # Deployment script
├── scripts/
│   └── deploy.js                      # Alternative deployment
├── public/
│   ├── index.html                     # Original frontend
│   └── index-fhevm.html              # FHEVM frontend
├── hardhat.config.js                  # Hardhat configuration
├── package-hardhat.json               # Dependencies for development
└── TUTORIAL.md                        # This tutorial
```

### Step 3: Install Development Dependencies

```bash
# Install Hardhat and FHEVM dependencies
npm install --save-dev @nomicfoundation/hardhat-toolbox hardhat hardhat-deploy
npm install fhevm tfhe
```

## 📚 Understanding the Smart Contract

Let's examine the key parts of our FHEVM smart contract:

### Importing FHEVM Libraries

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "fhevm/lib/TFHE.sol";
```

The `TFHE.sol` library provides all the functions needed for homomorphic encryption operations.

### Encrypted Data Types

```solidity
struct CharityProject {
    uint256 id;
    string name;
    string description;
    string category;
    uint256 targetAmount;
    euint64 encryptedRaisedAmount; // 🔐 Encrypted total raised
    address payable beneficiary;
    bool isActive;
    uint256 createdAt;
}

struct EncryptedDonation {
    uint256 projectId;
    euint64 encryptedAmount;    // 🔐 Encrypted donation amount
    address donor;
    uint256 timestamp;
    ebool isAnonymous;         // 🔐 Encrypted anonymity flag
}
```

Notice the encrypted types:
- `euint64`: Encrypted 64-bit unsigned integer
- `ebool`: Encrypted boolean

### Encrypted Operations

```solidity
function makeDonation(
    uint256 _projectId,
    bytes calldata encryptedAmount,
    bytes calldata encryptedIsAnonymous
) external payable onlyActiveProject(_projectId) {
    require(msg.value > 0, "Donation amount must be greater than 0");

    // Convert encrypted inputs
    euint64 donationAmount = TFHE.asEuint64(encryptedAmount);
    ebool isAnonymous = TFHE.asBool(encryptedIsAnonymous);

    // Store encrypted donation
    EncryptedDonation memory donation = EncryptedDonation({
        projectId: _projectId,
        encryptedAmount: donationAmount,
        donor: msg.sender,
        timestamp: block.timestamp,
        isAnonymous: isAnonymous
    });

    projectDonations[_projectId].push(donation);
    userDonations[msg.sender].push(_projectId);

    // 🧮 Encrypted arithmetic: Add to total without decrypting!
    charityProjects[_projectId].encryptedRaisedAmount = TFHE.add(
        charityProjects[_projectId].encryptedRaisedAmount,
        donationAmount
    );

    // Update global total (also encrypted)
    encryptedTotalDonations = TFHE.add(encryptedTotalDonations, donationAmount);

    emit EncryptedDonationMade(_projectId, block.timestamp);
}
```

**Key FHEVM Concepts Demonstrated:**

1. **Input Conversion**: `TFHE.asEuint64()` and `TFHE.asBool()` convert encrypted bytes to typed encrypted values
2. **Encrypted Arithmetic**: `TFHE.add()` performs addition on encrypted numbers
3. **Privacy Preservation**: The blockchain never sees the actual donation amount

## 🌐 Understanding the Frontend

### FHEVM Client Integration

```javascript
// Import FHEVM client library
import { createFhevmInstance } from 'https://unpkg.com/fhevmjs@0.3.0/bundle/index.js';

// Initialize FHEVM instance
fhevmInstance = await createFhevmInstance({
    networkUrl: window.ethereum ? await window.ethereum.request({method: 'eth_chainId'}) : '0x1f41',
    gatewayUrl: "https://gateway.zama.ai/", // Zama's gateway for key management
});
```

### Encrypting User Input

```javascript
// Convert amount to Wei and then encrypt
const amountWei = ethers.utils.parseEther(amount);
const amountValue = parseInt(amountWei.toString());

// 🔐 Encrypt the donation amount using FHE
const encryptedAmount = fhevmInstance.encrypt64(amountValue);

// 🔐 Encrypt the anonymity preference
const encryptedIsAnonymous = fhevmInstance.encryptBool(isAnonymous);

// Submit encrypted data to smart contract
const tx = await contract.makeDonation(
    projectId,
    encryptedAmount,
    encryptedIsAnonymous,
    { value: amountWei, gasLimit: 500000 }
);
```

## 🚀 Running the Tutorial

### Method 1: Local Development

1. **Start Hardhat Node**:
```bash
npx hardhat node
```

2. **Deploy the Contract**:
```bash
npx hardhat deploy --network localhost
```

3. **Run the Frontend**:
```bash
# Serve the FHEVM frontend
python -m http.server 8000
# Or use any static file server
```

4. **Open in Browser**:
Navigate to `http://localhost:8000/public/index-fhevm.html`

### Method 2: Zama Devnet (Recommended)

1. **Configure Network**:
Update your `.env` file with a private key:
```bash
PRIVATE_KEY=your_private_key_without_0x_prefix
```

2. **Deploy to Zama**:
```bash
npx hardhat deploy --network zama
```

3. **Update Frontend**:
The contract address will be automatically updated in the frontend.

## 📖 Step-by-Step Walkthrough

### Step 1: Connect Your Wallet
- Click "Connect Wallet" button
- Approve MetaMask connection
- The dApp will initialize FHEVM libraries

### Step 2: Understanding the Interface
- **Blue Theme**: Indicates this is an FHEVM dApp
- **ENCRYPTED Badge**: Shows privacy features are active
- **Status Messages**: Keep you informed about encryption processes

### Step 3: Make Your First Encrypted Donation

1. **Select a Project**: Choose from the pre-created charity projects
2. **Enter Amount**: Input donation amount (e.g., 0.001 ETH)
3. **Choose Anonymity**: Check/uncheck the anonymous option
4. **Submit**: Watch as your data gets encrypted and submitted!

### Step 4: Observe the Privacy Magic

What happens when you submit:
1. ⚡ **Client-Side Encryption**: Your amount and anonymity preference are encrypted in your browser
2. 🚀 **Blockchain Submission**: Only encrypted data is sent to the blockchain
3. 🔐 **Encrypted Storage**: The smart contract stores and computes with encrypted values
4. 🧮 **Private Computation**: Total donations are calculated without revealing individual amounts
5. 🛡️ **Privacy Preserved**: Your sensitive data never appears in plain text on-chain

## 🔍 Exploring the Code

### Smart Contract Key Functions

1. **Constructor**: Initializes encrypted total donations to 0
```solidity
constructor() {
    encryptedTotalDonations = TFHE.asEuint64(0);
}
```

2. **Project Creation**: Creates new charity projects (metadata is public)
```solidity
function createProject(
    string memory _name,
    string memory _description,
    string memory _category,
    uint256 _targetAmount,
    address payable _beneficiary
) external
```

3. **Encrypted Donations**: Handles encrypted donation submission
```solidity
function makeDonation(
    uint256 _projectId,
    bytes calldata encryptedAmount,
    bytes calldata encryptedIsAnonymous
) external payable
```

4. **Authorized Decryption**: Allows beneficiaries to see their project totals
```solidity
function getEncryptedRaisedAmount(uint256 _projectId)
    external
    view
    returns (bytes memory)
{
    require(msg.sender == project.beneficiary, "Only beneficiary can view");
    return TFHE.serialize(project.encryptedRaisedAmount);
}
```

### Frontend Key Components

1. **FHEVM Initialization**: Sets up the encryption client
2. **Input Encryption**: Converts user input to encrypted format
3. **Transaction Submission**: Sends encrypted data to blockchain
4. **Status Updates**: Provides user feedback throughout the process

## 🧠 Understanding FHE Concepts

### What is Fully Homomorphic Encryption?

Imagine you have a locked box that can perform calculations without opening:
- You put encrypted numbers in the box
- The box adds, subtracts, or compares them
- The result comes out still encrypted
- Only you (with the key) can see the final answer

That's essentially what FHE does with blockchain data!

### FHEVM Data Types

| Type | Description | Use Case |
|------|-------------|----------|
| `euint8` | Encrypted 8-bit integer | Small numbers, counters |
| `euint16` | Encrypted 16-bit integer | Medium numbers, quantities |
| `euint32` | Encrypted 32-bit integer | Large numbers, prices |
| `euint64` | Encrypted 64-bit integer | Very large numbers, Wei amounts |
| `ebool` | Encrypted boolean | True/false, flags, preferences |

### FHEVM Operations

| Operation | Function | Description |
|-----------|----------|-------------|
| Addition | `TFHE.add(a, b)` | Add two encrypted numbers |
| Subtraction | `TFHE.sub(a, b)` | Subtract encrypted numbers |
| Multiplication | `TFHE.mul(a, b)` | Multiply encrypted numbers |
| Comparison | `TFHE.eq(a, b)` | Check if encrypted values are equal |
| Logical | `TFHE.and(a, b)` | Logical AND for encrypted booleans |

## 🐛 Troubleshooting

### Common Issues

1. **FHEVM Library Fails to Load**
   - Ensure you have a modern browser
   - Check internet connection
   - Try refreshing the page

2. **Contract Deployment Fails**
   - Verify your private key in `.env`
   - Ensure you have enough ETH for gas
   - Check network connectivity

3. **Encryption Takes Long Time**
   - This is normal! FHE operations are computationally intensive
   - Be patient during the encryption process
   - Consider using smaller test amounts

4. **Transaction Fails**
   - Check if you have sufficient ETH balance
   - Increase gas limit if needed
   - Verify the project ID exists

### Performance Notes

- FHE operations are slower than regular operations
- Encryption happens client-side and may take a few seconds
- Gas costs are higher for encrypted operations
- This is the trade-off for complete privacy!

## 🎯 Next Steps

Congratulations! You've built your first FHEVM dApp. Here's what you can explore next:

### Extend This Tutorial

1. **Add More Encrypted Fields**: Try encrypting donor addresses or project categories
2. **Implement Access Control**: Add role-based decryption permissions
3. **Build Analytics**: Create encrypted reporting without revealing sensitive data
4. **Add Time Locks**: Use encrypted timestamps for time-based features

### Advanced FHEVM Features

1. **Conditional Logic**: Use `TFHE.select()` for if-then-else with encrypted values
2. **Encrypted Arrays**: Store collections of encrypted data
3. **Cross-Contract Calls**: Share encrypted data between contracts
4. **Decryption Gates**: Implement sophisticated access control patterns

### Real-World Applications

1. **Private Voting**: Elections with encrypted votes
2. **Confidential Auctions**: Blind bidding systems
3. **Private DeFi**: Trading without revealing positions
4. **Healthcare Records**: HIPAA-compliant blockchain storage

## 📚 Additional Resources

### Documentation
- [Zama FHEVM Documentation](https://docs.zama.ai/fhevm)
- [TFHE Library Reference](https://docs.zama.ai/tfhe-rs)
- [FHEVM Examples](https://github.com/zama-ai/fhevm)

### Community
- [Zama Discord](https://discord.gg/zama)
- [FHEVM GitHub Discussions](https://github.com/zama-ai/fhevm/discussions)
- [Zama Blog](https://www.zama.ai/blog)

### Tools
- [FHEVM Hardhat Plugin](https://www.npmjs.com/package/hardhat-fhevm)
- [FHEVM JavaScript Client](https://www.npmjs.com/package/fhevmjs)
- [Zama Devnet](https://devnet.zama.ai)

## 💡 Key Takeaways

1. **Privacy by Default**: FHEVM makes privacy the default, not an afterthought
2. **Computational Privacy**: You can compute on encrypted data without decrypting it
3. **Selective Disclosure**: Data can be revealed only to authorized parties
4. **Developer Friendly**: FHEVM uses familiar Solidity syntax with new encrypted types
5. **Future Ready**: This technology will power the next generation of privacy-preserving applications

## 🏆 You Did It!

You've successfully completed the "Hello FHEVM" tutorial! You now understand:
- ✅ What FHEVM and FHE are
- ✅ How to write smart contracts with encrypted data
- ✅ How to encrypt user inputs in the frontend
- ✅ How to deploy and interact with FHEVM contracts
- ✅ The trade-offs between privacy and performance

Welcome to the future of privacy-preserving blockchain applications! 🚀

---

*This tutorial was designed to be the most beginner-friendly introduction to FHEVM. If you found any part confusing or have suggestions for improvement, please open an issue in the GitHub repository.*