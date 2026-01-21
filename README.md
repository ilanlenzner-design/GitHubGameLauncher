# 🎮 GitHub Game Launcher for Mac

Launch GitHub games locally with one click!

## What's Included:

- ✅ **Command-line tool** (`run-game`)
- ✅ **Desktop app** (GameLauncher.app)
- ✅ **Chrome extension** (one-click from GitHub)
- ✅ **Background service** (for Chrome extension)

## Installation:

### Option 1: Use the Installer Package (Recommended)

1. Double-click `GitHubGameLauncher.pkg`
2. Follow the installation wizard
3. Enter your password when prompted
4. Done!

### Option 2: Manual Installation

1. Copy files to your system:
   ```bash
   sudo cp payload/usr/local/bin/* /usr/local/bin/
   sudo cp -r payload/Applications/GameLauncher.app /Applications/
   ```

2. Run the setup script:
   ```bash
   sudo bash scripts/postinstall
   ```

## Setup (After Installation):

### 1. GitHub Authentication

Open Terminal and run:
```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

### 2. Install Chrome Extension

The Chrome extension files are installed at `~/game-launcher-extension`

1. Open Chrome and go to `chrome://extensions/`
2. Enable **Developer mode** (toggle in top right)
3. Click **Load unpacked**
4. Select the folder: `~/game-launcher-extension`
5. The extension will appear with a 🎮 icon in your toolbar

### 3. Start the Service (for Chrome Extension)

Open Terminal and run:
```bash
node ~/run-game-service.js
```

Keep this terminal window open while using the Chrome extension.

## How to Use:

### Method 1: Chrome Extension (Easiest)

1. Make sure the service is running (`node ~/run-game-service.js`)
2. Go to any GitHub repository page
3. Click the 🎮 icon in your Chrome toolbar
4. Click "Launch Game"
5. Game opens automatically when ready!

### Method 2: Desktop App

1. Double-click **GameLauncher** on your Desktop
2. Paste the GitHub repository URL
3. Click "Launch"
4. Game starts in Terminal!

### Method 3: Command Line

```bash
run-game https://github.com/user/repo/tree/branch-name
```

## Examples:

```bash
# Launch a game with full URL
run-game https://github.com/sett-backend/arrow_1_classic_gameplay/tree/T1009-SP1-1fb0f

# Or just the repo (uses main branch)
run-game https://github.com/user/some-game
```

## Features:

- ✅ **One-click launch** from GitHub pages
- ✅ **Automatic dependency installation**
- ✅ **Smart waiting** - opens browser only when webpack is ready
- ✅ **Works with private repos** (uses your GitHub auth)
- ✅ **Multiple launch methods** - choose what works best for you

## Troubleshooting:

**"gh: command not found"**
- Install GitHub CLI: `brew install gh`

**Chrome extension shows error**
- Make sure the service is running: `node ~/run-game-service.js`
- Check that port 3001 is not in use

**Game doesn't open**
- Check Terminal for error messages
- Ensure you have npm installed
- Verify GitHub authentication: `gh auth status`

## Uninstall:

```bash
sudo rm /usr/local/bin/run-github-game.sh
sudo rm /usr/local/bin/run-game-service.js
sudo rm -rf /Applications/GameLauncher.app
rm -rf ~/game-launcher-extension
```

Remove the alias from `~/.zshrc`:
```bash
# Remove this line:
alias run-game='~/run-github-game.sh'
```

## Support:

For issues or questions, contact the developer or check the documentation.

Enjoy launching games! 🎮🚀
