#!/bin/bash

# Script to automatically clone and run a game from a GitHub repository
# Usage: ./run-github-game.sh <github-url> [branch-name]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if URL is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a GitHub repository URL${NC}"
    echo "Usage: ./run-github-game.sh <github-url> [branch-name]"
    echo "Example: ./run-github-game.sh https://github.com/user/repo main"
    exit 1
fi

REPO_URL="$1"
BRANCH="${2:-main}"

# Clean the URL - remove /tree/branch-name if present
if [[ "$REPO_URL" == *"/tree/"* ]]; then
    # Extract branch from URL if not provided separately
    if [ "$BRANCH" = "main" ]; then
        BRANCH=$(echo "$REPO_URL" | sed -n 's#.*/tree/\([^/]*\).*#\1#p')
    fi
    # Remove /tree/branch-name from URL
    REPO_URL=$(echo "$REPO_URL" | sed 's#/tree/.*##')
fi

# Remove trailing .git if present
REPO_URL="${REPO_URL%.git}"

# Extract repository name from URL
REPO_NAME=$(basename "$REPO_URL")

# Create a games directory if it doesn't exist
GAMES_DIR="$HOME/games"
mkdir -p "$GAMES_DIR"

TARGET_DIR="$GAMES_DIR/$REPO_NAME"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GitHub Game Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Repository:${NC} $REPO_URL"
echo -e "${GREEN}Branch:${NC} $BRANCH"
echo -e "${GREEN}Target directory:${NC} $TARGET_DIR"
echo ""

# Check if directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${BLUE}Repository already exists. Pulling latest changes...${NC}"
    cd "$TARGET_DIR"

    # Always stash any changes (tracked or untracked) to avoid conflicts
    echo -e "${BLUE}Stashing any local changes...${NC}"
    git stash push --include-untracked -m "Auto-stash before game launch $(date)" 2>/dev/null || git stash 2>/dev/null || true

    git fetch origin
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
    git pull origin "$BRANCH" 2>/dev/null || true
else
    echo -e "${BLUE}Cloning repository...${NC}"
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        gh repo clone "$REPO_URL" "$TARGET_DIR"
        cd "$TARGET_DIR"
        git checkout "$BRANCH" 2>/dev/null || echo "Already on $BRANCH"
    else
        gh repo clone "$REPO_URL" "$TARGET_DIR" -- -b "$BRANCH"
        cd "$TARGET_DIR"
    fi
fi

echo ""
echo -e "${BLUE}Installing dependencies...${NC}"
npm install

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Starting game server...${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Game will be available at:${NC} http://localhost:3000"
echo -e "${GREEN}Press Ctrl+C to stop the server${NC}"
echo ""

# Run the dev server
npm run dev
