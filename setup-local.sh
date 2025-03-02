#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_ROOT=$(pwd)

# Project paths
SMART_CONTRACTS_DIR="$PROJECT_ROOT/smart_contracts"
ANCHOR_TOML="$SMART_CONTRACTS_DIR/Anchor.toml"
LIB_RS="$SMART_CONTRACTS_DIR/programs/voting_system/src/lib.rs"
CARGO_LOCK="$SMART_CONTRACTS_DIR/Cargo.lock"

# Function to handle Cargo.lock version
modify_cargo_lock() {
    local action=$1  # "downgrade" or "upgrade"
    echo -e "${YELLOW}Modifying Cargo.lock version...${NC}"

    if [ "$action" = "downgrade" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/version = 4/version = 3/' "$CARGO_LOCK"
        else
            sed -i 's/version = 4/version = 3/' "$CARGO_LOCK"
        fi
        echo "Downgraded Cargo.lock to version 3"
    elif [ "$action" = "upgrade" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/version = 3/version = 4/' "$CARGO_LOCK"
        else
            sed -i 's/version = 3/version = 4/' "$CARGO_LOCK"
        fi
        echo "Upgraded Cargo.lock to version 4"
    fi
}

# Function to update program IDs
update_program_ids() {
    local program_id=$1

    echo -e "${YELLOW}Updating program IDs...${NC}"

    # Create backups
    cp "$ANCHOR_TOML" "${ANCHOR_TOML}.backup"
    cp "$LIB_RS" "${LIB_RS}.backup"

    # Update Anchor.toml and lib.rs based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^voting_system = \".*\"$/voting_system = \"$program_id\"/" "$ANCHOR_TOML"
        sed -i '' "s/declare_id!(\".*\")/declare_id!(\"$program_id\")/" "$LIB_RS"
    else
        sed -i "s/^voting_system = \".*\"$/voting_system = \"$program_id\"/" "$ANCHOR_TOML"
        sed -i "s/declare_id!(\".*\")/declare_id!(\"$program_id\")/" "$LIB_RS"
    fi

    echo -e "${GREEN}Updated program ID to: $program_id${NC}"
    echo "Backups created at:"
    echo "- ${ANCHOR_TOML}.backup"
    echo "- ${LIB_RS}.backup"
}

# Function to verify Solana configuration
verify_solana_config() {
    echo -e "${YELLOW}Verifying Solana configuration...${NC}"

    local config=$(solana config get)
    if ! echo "$config" | grep -q "http://localhost:8899"; then
        echo -e "${RED}Warning: Solana is not configured for localhost${NC}"
        echo "Current configuration:"
        echo "$config"

        read -p "Would you like to set Solana to localhost? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            solana config set --url localhost
            echo -e "${GREEN}Solana configured to localhost${NC}"
        fi
    else
        echo -e "${GREEN}Solana is correctly configured for localhost${NC}"
    fi
}

# Function to get program ID
get_program_id() {
    local max_attempts=5
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        echo "Attempting to capture program ID (attempt $attempt of $max_attempts)..."
        sleep 2  # Wait between attempts

        # Get full output of the command
        local last_line=$(solana program show --programs | grep "[[:alnum:]]" | tail -n 1)
        if [ -z "$last_line" ]; then
            attempt=$((attempt + 1))
            continue
        fi

        # Extract program ID (first column)
        local captured_id=$(echo "$last_line" | awk '{print $1}')

        # Validate program ID format
        if [[ $captured_id =~ ^[1-9A-HJ-NP-Za-km-z]{32,44}$ ]]; then
            echo -e "${GREEN}Successfully captured program ID: $captured_id${NC}"
            echo "$captured_id"  # Return the ID
            return 0
        fi

        attempt=$((attempt + 1))
    done

    echo -e "${RED}Failed to capture program ID after $max_attempts attempts${NC}" >&2
    return 1
}

# Main function
main() {
    echo -e "${GREEN}Starting project configuration...${NC}"

    # Verify we're in the correct directory
    if [ ! -d "$SMART_CONTRACTS_DIR" ]; then
        echo -e "${RED}Error: Are you in the project root directory?${NC}"
        echo "Could not find: $SMART_CONTRACTS_DIR"
        exit 1
    fi

    # Check Solana configuration
    verify_solana_config

    # Build and deploy process
    echo -e "${YELLOW}Starting build and deploy process...${NC}"

    # Step 1: Modify Cargo.lock
    modify_cargo_lock "downgrade"

    # Step 2: Build project
    echo "Building project..."
    cd "$SMART_CONTRACTS_DIR"
    if ! anchor build; then
        echo -e "${RED}Error: Build failed${NC}"
        modify_cargo_lock "upgrade"
        cd "$PROJECT_ROOT"
        exit 1
    fi

    # Step 3: Deploy program
    echo "Deploying program..."
    if ! anchor deploy; then
        echo -e "${RED}Error: Deployment failed${NC}"
        modify_cargo_lock "upgrade"
        cd "$PROJECT_ROOT"
        exit 1
    fi

    # Step 4: Capture program ID
    local program_id=$(get_program_id)
    if [ $? -ne 0 ]; then
        modify_cargo_lock "upgrade"
        cd "$PROJECT_ROOT"
        exit 1
    fi

    # Step 5: Update program IDs
    cd "$PROJECT_ROOT"  # Return to project root for correct path resolution
    if [ -n "$program_id" ]; then
        update_program_ids "$program_id"
    else
        echo -e "${RED}Error: No program ID captured${NC}"
        modify_cargo_lock "upgrade"
        exit 1
    fi

    # Step 6: Rebuild with new program ID
    cd "$SMART_CONTRACTS_DIR"
    echo "Rebuilding with new program ID..."
    if ! anchor build; then
        echo -e "${RED}Error: Rebuild failed${NC}"
        echo "Restoring backups..."
        cd "$PROJECT_ROOT"
        cp "${ANCHOR_TOML}.backup" "$ANCHOR_TOML"
        cp "${LIB_RS}.backup" "$LIB_RS"
        modify_cargo_lock "upgrade"
        exit 1
    fi

    # Step 7: Clean up
    cd "$PROJECT_ROOT"
    modify_cargo_lock "upgrade"
    cd "$SMART_CONTRACTS_DIR"
    anchor clean
    cd "$PROJECT_ROOT"

    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo "Program ID: $program_id"
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Start your backend: cd backend && cargo run"
    echo "2. Start your frontend: cd frontend && flutter run -d web-server --web-port=4040"
}

main
