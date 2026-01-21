#!/bin/bash

# Script to automatically clone and run a game from a GitHub repository
# Usage: ./run-github-game.sh <github-url> [branch-name]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if URL is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a GitHub repository URL${NC}"
    echo "Usage: ./run-github-game.sh <github-url> [branch-name]"
    echo "Example: ./run-github-game.sh https://github.com/user/repo main"
    exit 1
fi

REPO_URL="$1"
BRANCH="${2:-}"

# Clean the URL - remove /tree/branch-name if present
if [[ "$REPO_URL" == *"/tree/"* ]]; then
    # Extract branch from URL
    BRANCH=$(echo "$REPO_URL" | sed -n 's#.*/tree/\([^/]*\).*#\1#p')
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
if [ ! -z "$BRANCH" ]; then
    echo -e "${GREEN}Branch:${NC} $BRANCH"
fi
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

    if [ ! -z "$BRANCH" ]; then
        # Specific branch requested
        git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
        git pull origin "$BRANCH" 2>/dev/null || true
    else
        # No branch specified, use current branch or default
        CURRENT_BRANCH=$(git branch --show-current)
        if [ -z "$CURRENT_BRANCH" ]; then
            # Get default branch from remote
            DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
            git checkout "$DEFAULT_BRANCH" 2>/dev/null || git checkout -b "$DEFAULT_BRANCH" origin/"$DEFAULT_BRANCH"
            git pull origin "$DEFAULT_BRANCH" 2>/dev/null || true
        else
            git pull origin "$CURRENT_BRANCH" 2>/dev/null || true
        fi
    fi
else
    echo -e "${BLUE}Cloning repository...${NC}"
    if [ ! -z "$BRANCH" ]; then
        gh repo clone "$REPO_URL" "$TARGET_DIR" -- -b "$BRANCH"
    else
        gh repo clone "$REPO_URL" "$TARGET_DIR"
    fi
    cd "$TARGET_DIR"
fi

# Check if package.json exists (this is a Node.js project)
if [ ! -f "package.json" ]; then
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  No package.json found${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo -e "${YELLOW}This repository doesn't appear to be a game.${NC}"
    echo -e "${YELLOW}Package.json is missing - cannot install dependencies or run dev server.${NC}"
    echo ""
    echo -e "${BLUE}Repository cloned to:${NC} $TARGET_DIR"
    echo ""
    exit 0
fi

echo ""
echo -e "${BLUE}Installing dependencies...${NC}"
npm install

# Kill any existing process on port 3000
echo ""
PORT_PID=$(lsof -ti:3000 2>/dev/null || true)
if [ ! -z "$PORT_PID" ]; then
    echo -e "${YELLOW}Stopping existing game server on port 3000...${NC}"
    kill -9 $PORT_PID 2>/dev/null || true
    sleep 1
fi

# Get current branch for display
CURRENT_BRANCH=$(git branch --show-current)

# Create a banner injection script
cat > /tmp/inject-banner.js << 'EOF'
const fs = require('fs');
const path = require('path');

// Get repo info from command line args
const repoPath = process.argv[2];
const branch = process.argv[3];

// Find the main HTML file (usually index.html in dist, public, or src)
const possiblePaths = [
    'dist/index.html',
    'public/index.html',
    'src/index.html',
    'index.html'
];

let htmlPath = null;
for (const p of possiblePaths) {
    const fullPath = path.join(process.cwd(), p);
    if (fs.existsSync(fullPath)) {
        htmlPath = fullPath;
        break;
    }
}

if (htmlPath) {
    let html = fs.readFileSync(htmlPath, 'utf8');

    const banner = `
    <div id="repo-banner" style="position: fixed; top: 0; left: 0; right: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 8px 16px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; font-size: 12px; z-index: 999999; box-shadow: 0 2px 10px rgba(0,0,0,0.2); display: flex; justify-content: space-between; align-items: center; user-select: text; -webkit-user-select: text; -moz-user-select: text; -ms-user-select: text;">
        <div style="user-select: text; -webkit-user-select: text; -moz-user-select: text; -ms-user-select: text;">
            <strong>📁 Local Repository:</strong> <span style="user-select: text; -webkit-user-select: text;">${repoPath}</span>
            ${branch ? `<span style="margin-left: 12px; user-select: text; -webkit-user-select: text;">🌿 <strong>Branch:</strong> ${branch}</span>` : ''}
        </div>
        <button onclick="document.getElementById('repo-banner').style.display='none'" style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white; padding: 4px 12px; border-radius: 4px; cursor: pointer; font-size: 11px; font-weight: 600; user-select: none;">✕ Close</button>
    </div>
    <style>
        body { margin-top: 38px !important; }
        #repo-banner * { user-select: text !important; -webkit-user-select: text !important; }
        #repo-banner button { user-select: none !important; -webkit-user-select: none !important; }
    </style>
    `;

    // Try to inject after <body> tag
    if (html.includes('<body>')) {
        html = html.replace('<body>', '<body>' + banner);
    } else if (html.includes('<body')) {
        html = html.replace(/(<body[^>]*>)/, '$1' + banner);
    } else {
        // If no body tag, inject at the start
        html = banner + html;
    }

    fs.writeFileSync(htmlPath, html, 'utf8');
    console.log('✓ Banner injected into', htmlPath);
}
EOF

# Try to inject the banner (non-blocking, won't fail if it doesn't work)
node /tmp/inject-banner.js "$TARGET_DIR" "$CURRENT_BRANCH" 2>/dev/null || true

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Starting game server...${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Game will be available at:${NC} http://localhost:3000"
echo -e "${GREEN}Opening browser...${NC}"
echo -e "${GREEN}Press Ctrl+C to stop the server${NC}"
echo ""

# Open browser after a short delay (in background)
(sleep 3 && open http://localhost:3000) &

# Run the dev server
npm run dev
