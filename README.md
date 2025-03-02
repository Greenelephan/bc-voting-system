# Blockchain Voting System

## Prerequisites

Make sure you have the following versions installed:

| Component | Version |
|-----------|---------|
| Rustc | 1.84.0 |
| Anchor | 0.30.1 |
| Flutter | 3.27.1 |
| Dart | 3.6.0 |
| DevTools Flutter | 2.40.2 |
| Solana CLI | 2.0.22 |

## Setup Instructions

### 1. Solana Configuration

1. Install Solana following the [official instructions](https://docs.solana.com/cli/install-solana-cli-tools)
2. Verify installation:
   ```bash
   solana --version
   ```
3. Generate a new Solana keypair:
   ```bash
   solana-keygen new -o ~/.config/solana/id.json
   ```
   - You can verify your key with:
     ```bash
     solana address
     ```
4. Check your Solana configuration:
   ```bash
   solana config get
   ```
   Ensure your configuration matches:
   ```
   Config File: ~/.config/solana/cli/config.yml
   RPC URL: http://localhost:8899
   WebSocket URL: ws://localhost:8900/ (computed)
   Keypair Path: ~/.config/solana/id.json
   Commitment: confirmed
   ```
   - If URLs are not pointing to localhost, set them with:
     ```bash
     solana config set --url localhost
     ```
5. Check your balance:
   ```bash
   solana balance
   ```
   Should show approximately 500000000 SOL

### 2. Anchor Setup

1. Install Anchor following the [official instructions](https://www.anchor-lang.com/docs/installation)
2. Verify installation:
   ```bash
   anchor --version
   ```

### 3. Smart Contract Deployment

You have two options for deploying the smart contracts:

First of all start the local blockchain in the project root directory:
   ```bash
   solana-test-validator
   ```
   - To reset the blockchain:
     ```bash
     solana-test-validator --reset
     ```

#### Option 1: Automated Deployment (Recommended)

1. Make the setup script executable:
   ```bash
   chmod +x setup-local.sh
   ```

2. Run the automated setup:
   ```bash
   ./setup-local.sh
   ```

This script will:
- Handle Cargo.lock version changes automatically
- Build and deploy the smart contract
- Capture the program ID
- Update configuration files

#### Option 2: Manual Deployment

1. Navigate to the smart contracts directory:
   ```bash
   cd blockchain_wahlsystem/smart_contracts
   ```


2. Build the project:
   ```bash
   anchor build
   ```

     **Important**: Change version from 4 to 3 in `Cargo.lock` file (temporary fix for Anchor)
3. Deploy the program:
   ```bash
   anchor deploy
   ```

4. Update program ID:
   - Replace the program ID in:
     - `smart_contracts/Anchor.toml` (line 6)
     - `smart_contracts/programs/voting_system/src/lib.rs` (line 12)

5. Verify deployment:
   ```bash
   solana program show --programs
   ```
   You should see output similar to:
   ```
   Program Id                                   | Slot      | Authority                                    | Balance
   3aDGw2gUcwqkhfewhfqcekfekwjf445234hk5bSduAxK | 808       | Gw6MgNhhJFEKFHhfewjfkle94283to3r8PfdRo8EHSZT | 2.0217756 SOL
   ```

6. Rebuild to apply ID updates:
   ```bash
   anchor build
   ```

7. (Optional) Clean up:
   ```bash
   anchor clean
   ```
   Note: After cleaning, `Cargo.lock` version can be set back to 4

### 4. Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd blockchain-wahlsystem/backend
   ```

2. Build and run:
   ```bash
   cargo build
   cargo run
   ```

### 5. Frontend Setup

1. Install Flutter following the [official instructions](https://flutter.dev/docs/get-started/install)

2. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

3. Run the web server:
   ```bash
   flutter run -d web-server --web-port=4040
   ```

The application will be available at `localhost:4040`
