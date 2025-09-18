# Getting Started with Hello FHEVM 🚀

This quick-start guide will get you up and running with your first encrypted dApp in under 10 minutes!

## ⚡ 5-Minute Quick Start

### Step 1: Prerequisites Check ✅

Make sure you have:
- **Node.js 16+** installed ([Download here](https://nodejs.org/))
- **MetaMask** browser extension ([Install here](https://metamask.io/))
- **Basic Solidity knowledge** (can read simple smart contracts)
- **Git** for cloning the repository

**Test your setup:**
```bash
node --version    # Should show v16 or higher
npm --version     # Should show 8 or higher
git --version     # Should show git version
```

### Step 2: Clone and Install 📦

```bash
# Clone the repository
git clone <your-repository-url>
cd hello-fhevm-charity-dapp

# Install dependencies
npm install

# Copy environment template
cp .env.example .env
```

### Step 3: Choose Your Path 🛤️

**Option A: Local Development (Fastest)**
```bash
# Terminal 1: Start local blockchain
npx hardhat node

# Terminal 2: Deploy contract
npx hardhat deploy --network localhost

# Terminal 3: Start web server
python -m http.server 8000
# OR: npx serve . -p 8000
```

**Option B: Zama Devnet (Recommended)**
```bash
# Add your private key to .env
echo "PRIVATE_KEY=your_private_key_here" >> .env

# Deploy to Zama devnet
npx hardhat deploy --network zama

# Start web server
python -m http.server 8000
```

### Step 4: Open Your dApp 🌐

Navigate to: `http://localhost:8000/public/index-fhevm.html`

**You should see:**
- 🔐 Blue "Hello FHEVM" interface
- "ENCRYPTED" badge in the header
- "Connect Wallet" button
- Status messages explaining FHEVM initialization

## 🎯 What to Do Next

### Your First Encrypted Donation

1. **Connect MetaMask**
   - Click "Connect Wallet"
   - Approve the connection
   - Wait for FHEVM initialization

2. **Fill the Donation Form**
   - Select a charity project
   - Enter amount (try 0.001 ETH)
   - Choose anonymity preference
   - Click "Submit Encrypted Donation"

3. **Watch the Magic** ✨
   - Your inputs get encrypted client-side
   - Encrypted data is sent to blockchain
   - Transaction completes with privacy preserved!

## 🔍 Understanding What Just Happened

### Regular vs FHEVM Transaction

**Regular Smart Contract:**
```
User Input: "I want to donate 0.5 ETH anonymously"
Blockchain: "User 0x123... donated 0.5 ETH anonymously to Project 1"
Everyone can see: ✅ Amount, ✅ Anonymity choice, ✅ All details
```

**FHEVM Smart Contract:**
```
User Input: "I want to donate 0.5 ETH anonymously"
Client Encryption: Converts to encrypted bytes
Blockchain: "User 0x123... made encrypted donation to Project 1"
Everyone can see: ❌ Amount, ❌ Anonymity choice, ✅ Only that a donation occurred
```

## 🛠️ Development Commands

### Essential Commands
```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy locally
npx hardhat deploy --network localhost

# Deploy to Zama devnet
npx hardhat deploy --network zama

# Start development server
npm start
```

### Useful Development Commands
```bash
# Clean and rebuild
npx hardhat clean && npx hardhat compile

# Check contract size
npx hardhat size-contracts

# Generate TypeScript bindings (if using TypeScript)
npx hardhat typechain
```

## 🐛 Common Issues & Solutions

### Issue: "FHEVM library fails to load"
**Solution:**
- Use a modern browser (Chrome/Firefox/Safari)
- Ensure stable internet connection
- Try refreshing the page
- Check browser console for specific errors

### Issue: "Contract deployment fails"
**Fix:**
```bash
# Check your .env file has private key
cat .env | grep PRIVATE_KEY

# Make sure you have test ETH
# For local: Hardhat provides test accounts
# For Zama: Get test tokens from faucet
```

### Issue: "Encryption takes forever"
**This is normal!** FHE operations are computationally intensive:
- Client-side encryption: 2-5 seconds
- Blockchain transaction: 10-30 seconds
- Be patient - this is the trade-off for privacy

### Issue: "Transaction fails with 'revert'"
**Check:**
- Do you have enough ETH for gas?
- Is the project ID valid (1, 2, or 3)?
- Is your donation amount > 0?

## 📁 Project Structure Explained

```
hello-fhevm-charity-dapp/
├── contracts/
│   └── CharityDonationPlatform.sol  # 🔐 FHEVM smart contract
├── deploy/
│   └── 01-deploy-charity.js         # 🚀 Deployment automation
├── public/
│   ├── index.html                   # 📄 Original (non-encrypted)
│   └── index-fhevm.html            # 🔐 FHEVM version
├── test/
│   └── CharityPlatform.test.js      # 🧪 Test suite
├── .env.example                     # 🔧 Environment template
├── hardhat.config.js                # ⚙️ Hardhat configuration
└── TUTORIAL.md                      # 📚 Complete tutorial
```

## 🎓 Learning Path

Now that you're set up, here's your learning journey:

### Phase 1: Understanding (30 minutes)
1. Read [TUTORIAL.md](./TUTORIAL.md) sections 1-3
2. Examine `contracts/CharityDonationPlatform.sol`
3. Compare with `public/index.html` vs `public/index-fhevm.html`

### Phase 2: Hands-On (1 hour)
1. Make several test donations
2. Try different anonymity settings
3. Examine transactions in browser dev tools
4. Run the test suite: `npx hardhat test`

### Phase 3: Experimentation (2+ hours)
1. Modify the smart contract
2. Add new encrypted fields
3. Create custom UI elements
4. Deploy to different networks

## 🔗 Helpful Resources

### FHEVM Documentation
- [Official FHEVM Docs](https://docs.zama.ai/fhevm)
- [TFHE Library Reference](https://docs.zama.ai/tfhe-rs)
- [Zama Developer Portal](https://docs.zama.ai/)

### Development Tools
- [Hardhat Documentation](https://hardhat.org/docs)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [MetaMask Developer Docs](https://docs.metamask.io/)

### Community & Support
- [Zama Discord](https://discord.gg/zama)
- [FHEVM GitHub](https://github.com/zama-ai/fhevm)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/fhe)

## 🎯 Next Steps

Ready to dive deeper? Here's what to explore:

1. **Complete the Full Tutorial**: [TUTORIAL.md](./TUTORIAL.md)
2. **Examine the Smart Contract**: Understand encrypted data types and operations
3. **Experiment with Frontend**: Modify `index-fhevm.html` to add features
4. **Run Tests**: Execute `npx hardhat test` to see how FHEVM contracts are tested
5. **Build Your Own**: Create a new encrypted dApp from scratch

## 💡 Pro Tips

### Development Best Practices
- **Start Small**: Begin with simple encrypted operations
- **Test Locally First**: Use Hardhat network before deploying to testnet
- **Monitor Gas Usage**: Encrypted operations cost more gas
- **Handle Async Operations**: Client-side encryption is asynchronous

### Privacy Considerations
- **Not Everything Needs Encryption**: Only encrypt sensitive data
- **Plan Access Control**: Decide who can decrypt what data
- **User Experience**: Inform users about encryption delays
- **Key Management**: Understand FHEVM's key management system

## 🎉 Congratulations!

You've successfully set up your first FHEVM development environment!

You're now ready to explore the fascinating world of privacy-preserving smart contracts. Remember: FHEVM represents the cutting edge of blockchain privacy technology - you're among the first developers to build with these capabilities.

**Happy encrypting! 🔐**

---

**Need Help?**
- Check the [full tutorial](./TUTORIAL.md) for detailed explanations
- Join the [Zama Discord](https://discord.gg/zama) community
- Open an issue in the GitHub repository