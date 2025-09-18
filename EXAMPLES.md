# FHEVM Code Examples & Patterns 🧩

This document provides copy-paste ready code examples for common FHEVM patterns. Perfect for learning and building your own encrypted dApps!

## 🔐 Basic Encrypted Data Types

### Simple Encrypted Storage
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "fhevm/lib/TFHE.sol";

contract BasicEncryption {
    // Encrypted state variables
    euint64 private encryptedBalance;
    ebool private encryptedFlag;
    euint32 private encryptedScore;

    // Initialize encrypted values
    constructor() {
        encryptedBalance = TFHE.asEuint64(0);
        encryptedFlag = TFHE.asBool(false);
        encryptedScore = TFHE.asEuint32(100);
    }

    // Set encrypted value from user input
    function setBalance(bytes calldata encryptedAmount) external {
        encryptedBalance = TFHE.asEuint64(encryptedAmount);
    }

    // Get encrypted value (only authorized users)
    function getBalance() external view returns (bytes memory) {
        // Add access control here
        return TFHE.serialize(encryptedBalance);
    }
}
```

## 🧮 Encrypted Arithmetic Operations

### Basic Math Operations
```solidity
contract EncryptedMath {
    euint64 private total;

    function demonstrateOperations(
        bytes calldata encryptedA,
        bytes calldata encryptedB
    ) external {
        euint64 a = TFHE.asEuint64(encryptedA);
        euint64 b = TFHE.asEuint64(encryptedB);

        // Addition
        euint64 sum = TFHE.add(a, b);

        // Subtraction
        euint64 difference = TFHE.sub(a, b);

        // Multiplication
        euint64 product = TFHE.mul(a, b);

        // Store result
        total = sum;
    }
}
```

### Encrypted Comparisons
```solidity
contract EncryptedComparisons {
    // Encrypted conditional logic
    function compareAndSelect(
        bytes calldata encryptedA,
        bytes calldata encryptedB
    ) external pure returns (bytes memory) {
        euint64 a = TFHE.asEuint64(encryptedA);
        euint64 b = TFHE.asEuint64(encryptedB);

        // Check if a equals b (result is encrypted)
        ebool isEqual = TFHE.eq(a, b);

        // Check if a is greater than b
        ebool isGreater = TFHE.gt(a, b);

        // Conditional selection: if a > b, return a, else return b
        euint64 maximum = TFHE.select(isGreater, a, b);

        return TFHE.serialize(maximum);
    }
}
```

## 🏦 Private Banking Example

### Encrypted Bank Account
```solidity
contract PrivateBank {
    mapping(address => euint64) private encryptedBalances;
    euint64 private totalSupply;

    event DepositMade(address indexed account, uint256 timestamp);
    event WithdrawalMade(address indexed account, uint256 timestamp);

    constructor() {
        totalSupply = TFHE.asEuint64(0);
    }

    // Deposit with encrypted amount
    function deposit(bytes calldata encryptedAmount) external payable {
        require(msg.value > 0, "Must send ETH");

        euint64 amount = TFHE.asEuint64(encryptedAmount);

        // Add to user balance
        encryptedBalances[msg.sender] = TFHE.add(
            encryptedBalances[msg.sender],
            amount
        );

        // Add to total supply
        totalSupply = TFHE.add(totalSupply, amount);

        emit DepositMade(msg.sender, block.timestamp);
    }

    // Transfer between accounts (amounts stay encrypted)
    function transfer(
        address to,
        bytes calldata encryptedAmount
    ) external {
        euint64 amount = TFHE.asEuint64(encryptedAmount);

        // Check if sender has sufficient balance
        ebool hasSufficientBalance = TFHE.gte(
            encryptedBalances[msg.sender],
            amount
        );

        // Only proceed if balance is sufficient
        // Note: In production, you'd want more sophisticated error handling

        // Subtract from sender
        encryptedBalances[msg.sender] = TFHE.sub(
            encryptedBalances[msg.sender],
            amount
        );

        // Add to recipient
        encryptedBalances[to] = TFHE.add(
            encryptedBalances[to],
            amount
        );
    }

    // Get balance (only account owner)
    function getMyBalance() external view returns (bytes memory) {
        return TFHE.serialize(encryptedBalances[msg.sender]);
    }
}
```

## 🗳️ Private Voting System

### Anonymous Voting
```solidity
contract PrivateVoting {
    struct Proposal {
        string description;
        euint64 yesVotes;
        euint64 noVotes;
        uint256 deadline;
        bool active;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => ebool)) private hasVoted;
    uint256 public nextProposalId = 1;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event VoteCast(uint256 indexed proposalId, uint256 timestamp);

    // Create a new proposal
    function createProposal(
        string calldata description,
        uint256 votingPeriod
    ) external {
        proposals[nextProposalId] = Proposal({
            description: description,
            yesVotes: TFHE.asEuint64(0),
            noVotes: TFHE.asEuint64(0),
            deadline: block.timestamp + votingPeriod,
            active: true
        });

        emit ProposalCreated(nextProposalId, description);
        nextProposalId++;
    }

    // Cast encrypted vote
    function vote(
        uint256 proposalId,
        bytes calldata encryptedVote // true for yes, false for no
    ) external {
        require(proposals[proposalId].active, "Proposal not active");
        require(block.timestamp <= proposals[proposalId].deadline, "Voting ended");

        ebool vote = TFHE.asBool(encryptedVote);

        // Ensure user hasn't voted (simplified check)
        // In production, implement more sophisticated double-voting prevention

        // Convert boolean vote to numeric values for counting
        euint64 yesVote = TFHE.select(vote, TFHE.asEuint64(1), TFHE.asEuint64(0));
        euint64 noVote = TFHE.select(vote, TFHE.asEuint64(0), TFHE.asEuint64(1));

        // Add votes to totals
        proposals[proposalId].yesVotes = TFHE.add(
            proposals[proposalId].yesVotes,
            yesVote
        );

        proposals[proposalId].noVotes = TFHE.add(
            proposals[proposalId].noVotes,
            noVote
        );

        // Mark as voted
        hasVoted[msg.sender][proposalId] = TFHE.asBool(true);

        emit VoteCast(proposalId, block.timestamp);
    }
}
```

## 🎯 Private Auction System

### Sealed Bid Auction
```solidity
contract PrivateAuction {
    struct Auction {
        string item;
        address seller;
        euint64 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => euint64)) private bids;
    uint256 public nextAuctionId = 1;

    event AuctionCreated(uint256 indexed auctionId, string item);
    event BidPlaced(uint256 indexed auctionId, address bidder, uint256 timestamp);
    event AuctionEnded(uint256 indexed auctionId, address winner);

    // Create auction
    function createAuction(
        string calldata item,
        uint256 duration
    ) external {
        auctions[nextAuctionId] = Auction({
            item: item,
            seller: msg.sender,
            highestBid: TFHE.asEuint64(0),
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });

        emit AuctionCreated(nextAuctionId, item);
        nextAuctionId++;
    }

    // Place encrypted bid
    function placeBid(
        uint256 auctionId,
        bytes calldata encryptedBidAmount
    ) external payable {
        require(auctions[auctionId].active, "Auction not active");
        require(block.timestamp <= auctions[auctionId].endTime, "Auction ended");

        euint64 bidAmount = TFHE.asEuint64(encryptedBidAmount);

        // Store the bid
        bids[auctionId][msg.sender] = bidAmount;

        // Compare with current highest bid
        ebool isHigher = TFHE.gt(bidAmount, auctions[auctionId].highestBid);

        // Update highest bid if this bid is higher
        auctions[auctionId].highestBid = TFHE.select(
            isHigher,
            bidAmount,
            auctions[auctionId].highestBid
        );

        // Update highest bidder if this bid is higher
        if (TFHE.decrypt(isHigher)) { // Note: In practice, avoid decryption
            auctions[auctionId].highestBidder = msg.sender;
        }

        emit BidPlaced(auctionId, msg.sender, block.timestamp);
    }
}
```

## 📊 Private Analytics

### Encrypted Data Collection
```solidity
contract PrivateAnalytics {
    struct Survey {
        string question;
        euint64 totalResponses;
        euint64 sumOfRatings;
        uint256 responseCount;
    }

    mapping(uint256 => Survey) public surveys;
    uint256 public nextSurveyId = 1;

    // Create survey
    function createSurvey(string calldata question) external {
        surveys[nextSurveyId] = Survey({
            question: question,
            totalResponses: TFHE.asEuint64(0),
            sumOfRatings: TFHE.asEuint64(0),
            responseCount: 0
        });
        nextSurveyId++;
    }

    // Submit encrypted response
    function submitResponse(
        uint256 surveyId,
        bytes calldata encryptedRating // Rating from 1-10
    ) external {
        euint64 rating = TFHE.asEuint64(encryptedRating);

        // Add to total responses
        surveys[surveyId].totalResponses = TFHE.add(
            surveys[surveyId].totalResponses,
            TFHE.asEuint64(1)
        );

        // Add to sum of ratings
        surveys[surveyId].sumOfRatings = TFHE.add(
            surveys[surveyId].sumOfRatings,
            rating
        );

        // Increment response count (for average calculation)
        surveys[surveyId].responseCount++;
    }

    // Get encrypted average (only survey creator)
    function getEncryptedAverage(uint256 surveyId) external view returns (bytes memory) {
        // In practice, add access control

        // Calculate average: sum / count
        euint64 average = TFHE.div(
            surveys[surveyId].sumOfRatings,
            TFHE.asEuint64(surveys[surveyId].responseCount)
        );

        return TFHE.serialize(average);
    }
}
```

## 🎮 Encrypted Game Example

### Private Game State
```solidity
contract EncryptedGame {
    struct Player {
        euint32 health;
        euint32 score;
        euint8 level;
        ebool isAlive;
    }

    mapping(address => Player) private players;
    euint32 private globalHighScore;

    event PlayerJoined(address indexed player);
    event GameAction(address indexed player, uint256 timestamp);

    constructor() {
        globalHighScore = TFHE.asEuint32(0);
    }

    // Join game with encrypted initial stats
    function joinGame(
        bytes calldata encryptedHealth,
        bytes calldata encryptedScore
    ) external {
        players[msg.sender] = Player({
            health: TFHE.asEuint32(encryptedHealth),
            score: TFHE.asEuint32(encryptedScore),
            level: TFHE.asEuint8(1),
            isAlive: TFHE.asBool(true)
        });

        emit PlayerJoined(msg.sender);
    }

    // Perform game action (damage/healing/scoring)
    function gameAction(
        bytes calldata encryptedHealthChange,
        bytes calldata encryptedScoreChange
    ) external {
        require(TFHE.decrypt(players[msg.sender].isAlive), "Player is dead");

        euint32 healthChange = TFHE.asEuint32(encryptedHealthChange);
        euint32 scoreChange = TFHE.asEuint32(encryptedScoreChange);

        // Update health
        players[msg.sender].health = TFHE.add(
            players[msg.sender].health,
            healthChange
        );

        // Update score
        players[msg.sender].score = TFHE.add(
            players[msg.sender].score,
            scoreChange
        );

        // Check if player died (health <= 0)
        ebool isDead = TFHE.le(players[msg.sender].health, TFHE.asEuint32(0));
        players[msg.sender].isAlive = TFHE.not(isDead);

        // Update global high score if needed
        ebool isNewHighScore = TFHE.gt(
            players[msg.sender].score,
            globalHighScore
        );

        globalHighScore = TFHE.select(
            isNewHighScore,
            players[msg.sender].score,
            globalHighScore
        );

        emit GameAction(msg.sender, block.timestamp);
    }
}
```

## 🌐 Frontend Integration Examples

### JavaScript Client-Side Encryption
```javascript
// Initialize FHEVM instance
import { createFhevmInstance } from 'fhevmjs';

class FHEVMClient {
    constructor() {
        this.fhevm = null;
        this.contract = null;
    }

    async init() {
        // Initialize FHEVM
        this.fhevm = await createFhevmInstance({
            networkUrl: "http://localhost:8545", // Your RPC URL
            gatewayUrl: "https://gateway.zama.ai/",
        });

        // Setup contract
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        this.contract = new ethers.Contract(contractAddress, contractABI, signer);
    }

    // Encrypt a number
    async encryptNumber(value) {
        return this.fhevm.encrypt64(value);
    }

    // Encrypt a boolean
    async encryptBoolean(value) {
        return this.fhevm.encryptBool(value);
    }

    // Submit encrypted donation
    async makeEncryptedDonation(projectId, amount, isAnonymous) {
        try {
            // Convert amount to Wei
            const amountWei = ethers.utils.parseEther(amount.toString());

            // Encrypt the inputs
            const encryptedAmount = await this.encryptNumber(parseInt(amountWei.toString()));
            const encryptedAnonymous = await this.encryptBoolean(isAnonymous);

            // Submit transaction
            const tx = await this.contract.makeDonation(
                projectId,
                encryptedAmount,
                encryptedAnonymous,
                { value: amountWei }
            );

            return await tx.wait();

        } catch (error) {
            console.error('Encrypted donation failed:', error);
            throw error;
        }
    }

    // Decrypt data (for authorized users)
    async decryptValue(encryptedBytes) {
        // Note: This requires proper access control
        return this.fhevm.decrypt(encryptedBytes);
    }
}

// Usage example
async function example() {
    const client = new FHEVMClient();
    await client.init();

    // Make encrypted donation
    const receipt = await client.makeEncryptedDonation(
        1,           // Project ID
        0.1,         // 0.1 ETH
        true         // Anonymous
    );

    console.log('Donation successful:', receipt.transactionHash);
}
```

### React Component Example
```jsx
import React, { useState, useEffect } from 'react';
import { createFhevmInstance } from 'fhevmjs';

function EncryptedDonationForm() {
    const [fhevm, setFhevm] = useState(null);
    const [amount, setAmount] = useState('');
    const [isAnonymous, setIsAnonymous] = useState(true);
    const [loading, setLoading] = useState(false);
    const [status, setStatus] = useState('');

    useEffect(() => {
        initFHEVM();
    }, []);

    async function initFHEVM() {
        try {
            const instance = await createFhevmInstance({
                networkUrl: "http://localhost:8545",
                gatewayUrl: "https://gateway.zama.ai/",
            });
            setFhevm(instance);
            setStatus('FHEVM initialized ✅');
        } catch (error) {
            setStatus('Failed to initialize FHEVM ❌');
        }
    }

    async function submitDonation(e) {
        e.preventDefault();
        if (!fhevm) return;

        setLoading(true);
        setStatus('🔐 Encrypting donation...');

        try {
            // Encrypt inputs
            const amountWei = ethers.utils.parseEther(amount);
            const encryptedAmount = fhevm.encrypt64(parseInt(amountWei.toString()));
            const encryptedAnonymous = fhevm.encryptBool(isAnonymous);

            setStatus('🚀 Submitting to blockchain...');

            // Submit to contract (assuming contract is already initialized)
            const tx = await contract.makeDonation(
                1, // Project ID
                encryptedAmount,
                encryptedAnonymous,
                { value: amountWei }
            );

            setStatus('⏳ Waiting for confirmation...');
            await tx.wait();

            setStatus(`✅ Donation of ${amount} ETH submitted successfully!`);
            setAmount('');

        } catch (error) {
            setStatus('❌ Donation failed: ' + error.message);
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="donation-form">
            <h2>🔐 Encrypted Donation</h2>
            <p className="status">{status}</p>

            <form onSubmit={submitDonation}>
                <div>
                    <label>Amount (ETH):</label>
                    <input
                        type="number"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        step="0.001"
                        min="0.001"
                        required
                    />
                </div>

                <div>
                    <label>
                        <input
                            type="checkbox"
                            checked={isAnonymous}
                            onChange={(e) => setIsAnonymous(e.target.checked)}
                        />
                        Make donation anonymous
                    </label>
                </div>

                <button type="submit" disabled={!fhevm || loading}>
                    {loading ? 'Processing...' : '🚀 Donate Privately'}
                </button>
            </form>

            <div className="info">
                <h4>🔍 What happens when you submit:</h4>
                <ol>
                    <li>Your amount gets encrypted using FHE</li>
                    <li>Your anonymity preference gets encrypted</li>
                    <li>Encrypted data is sent to the smart contract</li>
                    <li>Contract computes on encrypted data</li>
                    <li>Your privacy is preserved throughout!</li>
                </ol>
            </div>
        </div>
    );
}

export default EncryptedDonationForm;
```

## 🧪 Testing Patterns

### FHEVM Test Utilities
```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FHEVM Testing Patterns", function() {
    let contract, fhevm;

    before(async function() {
        // Deploy contract
        const Contract = await ethers.getContractFactory("YourContract");
        contract = await Contract.deploy();

        // Initialize FHEVM for testing
        // Note: In actual tests, you'd use proper FHEVM testing utilities
    });

    it("Should handle encrypted inputs", async function() {
        // Test with known encrypted values
        const plainValue = 100;
        const encryptedValue = "0x1234..."; // Properly encrypted bytes

        await contract.submitEncryptedValue(encryptedValue);

        // Verify state changes (without decrypting)
        const event = await contract.queryFilter("ValueSubmitted");
        expect(event.length).to.equal(1);
    });

    it("Should perform encrypted arithmetic", async function() {
        const encryptedA = "0xabcd..."; // encrypt(50)
        const encryptedB = "0xef01..."; // encrypt(30)

        await contract.addEncryptedValues(encryptedA, encryptedB);

        // Test indirect verification methods
        const resultExists = await contract.hasResult();
        expect(resultExists).to.be.true;
    });
});
```

## 📚 Additional Resources

### Useful FHEVM Patterns
```solidity
// Pattern: Encrypted Counter
function incrementCounter(bytes calldata encryptedIncrement) external {
    euint32 increment = TFHE.asEuint32(encryptedIncrement);
    counter = TFHE.add(counter, increment);
}

// Pattern: Conditional Updates
function updateIfGreater(bytes calldata encryptedValue) external {
    euint64 newValue = TFHE.asEuint64(encryptedValue);
    ebool isGreater = TFHE.gt(newValue, currentValue);
    currentValue = TFHE.select(isGreater, newValue, currentValue);
}

// Pattern: Access-Controlled Decryption
function getDecryptedValue() external view returns (uint64) {
    require(msg.sender == owner, "Only owner can decrypt");
    return TFHE.decrypt(encryptedValue);
}
```

---

## 🎯 Next Steps

These examples provide a solid foundation for building with FHEVM. Remember:

1. **Start Simple**: Begin with basic encrypted storage and arithmetic
2. **Think Privacy-First**: Design your application with privacy as a core feature
3. **Test Thoroughly**: Encrypted operations have different failure modes
4. **Optimize Gas**: FHE operations are more expensive than regular operations
5. **Plan Access Control**: Decide who can decrypt what data

**Happy coding with FHEVM! 🔐🚀**