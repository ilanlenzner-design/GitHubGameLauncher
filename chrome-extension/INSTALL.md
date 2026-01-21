# 🎮 GitHub Game Launcher - Chrome Extension

Launch GitHub games locally with one click!

## Installation Instructions:

### Step 1: Install the Extension

1. Open Chrome and go to: `chrome://extensions/`
2. Enable **Developer mode** (toggle in top right corner)
3. Click **"Load unpacked"**
4. Select the folder: `/Users/ilan/game-launcher-extension`
5. The extension will appear in your toolbar with a 🎮 icon

### Step 2: Start the Launcher Service

The extension needs a local service to run. In Terminal, run:

```bash
node ~/run-game-service.js
```

Keep this terminal window open while using the extension.

## How to Use:

1. **Navigate** to any GitHub repository (e.g., `https://github.com/sett-backend/arrow_1_classic_gameplay/tree/branch-name`)
2. **Click** the 🎮 extension icon in your Chrome toolbar
3. **Click** "Launch Game" button
4. The game will automatically start cloning and launching in Terminal!

## Features:

- ✅ One-click launch from any GitHub repository page
- ✅ Automatically detects the repository URL and branch
- ✅ Works with private repositories (using your GitHub authentication)
- ✅ Clean and simple interface

## Troubleshooting:

**Extension shows "Error: Make sure the launcher service is running"**
- Make sure you ran `node ~/run-game-service.js` in Terminal
- Check that the service is running on port 3001

**"Not a GitHub repository page"**
- Make sure you're on a GitHub repository page (URL should be like `github.com/user/repo`)

## Alternative Methods:

If you prefer not to use the Chrome extension, you can also use:

1. **GameLauncher.app** - Double-click app on Desktop, paste URL
2. **Terminal command** - `run-game <github-url>`

Enjoy! 🎮
