# 🎮 GitHub Game Launcher

Launch GitHub-hosted games locally with one click! Perfect for testing and playing games directly from GitHub repositories.

![GitHub Game Launcher](https://img.shields.io/badge/platform-macOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

- 🚀 **One-click launch** from any GitHub repository page
- 🎯 **Chrome Extension** - Launch directly from GitHub in your browser
- 💻 **Desktop App** - Simple drag-and-drop interface
- ⌨️ **Command Line** - For power users
- 🔄 **Smart waiting** - Opens browser only when webpack compilation is complete
- 🔒 **Works with private repos** - Uses your GitHub authentication
- 📦 **Easy distribution** - Installable `.pkg` for macOS

## 🎥 Demo

The launcher automatically:
1. Clones the repository (or updates if already cloned)
2. Installs dependencies
3. Starts the dev server
4. Opens the game in your browser when ready

## 📦 Installation

### Prerequisites

- macOS (10.10+)
- [GitHub CLI](https://cli.github.com/) (`brew install gh`)
- Node.js (for npm dependencies)
- Chrome browser (for the extension)

### Quick Install

Download the latest [GitHubGameLauncher.pkg](https://github.com/ilanlenzner-design/GitHubGameLauncher/releases) and double-click to install.

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/ilanlenzner-design/GitHubGameLauncher.git
cd GitHubGameLauncher

# Install scripts
cp scripts/run-github-game.sh ~/run-github-game.sh
cp scripts/run-game-service.js ~/run-game-service.js
chmod +x ~/run-github-game.sh
chmod +x ~/run-game-service.js

# Add alias to .zshrc
echo "alias run-game='~/run-github-game.sh'" >> ~/.zshrc
source ~/.zshrc
```

## 🚀 Usage

### Method 1: Chrome Extension (Recommended)

1. **Install the extension:**
   - Open Chrome and go to `chrome://extensions/`
   - Enable **Developer mode**
   - Click **Load unpacked**
   - Select the `chrome-extension` folder

2. **Start the background service:**
   ```bash
   node ~/run-game-service.js
   ```

3. **Launch a game:**
   - Navigate to any GitHub repository page
   - Click the 🎮 extension icon
   - Click "Launch Game"
   - Game automatically opens when ready!

### Method 2: Desktop App

1. Double-click **GameLauncher.app**
2. Paste the GitHub repository URL
3. Click "Launch"

### Method 3: Command Line

```bash
# Launch with full URL
run-game https://github.com/user/repo/tree/branch-name

# Or just the repo URL (uses main branch)
run-game https://github.com/user/repo
```

## 📖 Examples

```bash
# Launch a specific branch
run-game https://github.com/sett-backend/arrow_1_classic_gameplay/tree/T1009-SP1-1fb0f

# Launch from main branch
run-game https://github.com/sett-backend/domino_legends_1_jamaica

# The URL from GitHub's address bar works too
run-game https://github.com/user/repo/tree/feature-branch
```

## 🔧 How It Works

1. **URL Parsing**: Extracts repository info and branch from GitHub URL
2. **Clone/Update**: Uses GitHub CLI to clone or update the repository
3. **Dependencies**: Runs `npm install` automatically
4. **Dev Server**: Starts `npm run dev`
5. **Smart Opening**: Polls localhost:3000 until webpack finishes compiling
6. **Browser Launch**: Opens the game only when it's actually ready

## 📁 Project Structure

```
GitHubGameLauncher/
├── scripts/
│   ├── run-github-game.sh      # Main launcher script
│   └── run-game-service.js     # Background service for Chrome extension
├── chrome-extension/
│   ├── manifest.json           # Extension configuration
│   ├── popup.html              # Extension popup UI
│   ├── popup.js                # Popup logic
│   └── background.js           # Background service worker
├── app/
│   └── GameLauncher.app        # macOS desktop application
└── README.md
```

## 🛠️ Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/ilanlenzner-design/GitHubGameLauncher.git
cd GitHubGameLauncher

# Make scripts executable
chmod +x scripts/*.sh

# Test the launcher
./scripts/run-github-game.sh https://github.com/user/test-repo
```

### Creating the .pkg Installer

```bash
# Build the installer package
./build-installer.sh
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Requirements

The launcher works with games that have:
- `package.json` with dependencies
- `npm run dev` command that starts a dev server
- Server running on `localhost:3000`

## 🐛 Troubleshooting

**"gh: command not found"**
```bash
brew install gh
gh auth login
```

**Chrome extension shows "Error: Make sure the launcher service is running"**
```bash
node ~/run-game-service.js
```

**Port 3000 already in use**
- Stop any running dev servers
- Or modify the port in the game's configuration

**npm install fails**
- Ensure you have Node.js installed
- Check GitHub authentication: `gh auth status`

## 📄 License

MIT License - feel free to use this for your own projects!

## 🙏 Acknowledgments

- Built for the Sett game development team
- Uses GitHub CLI for authentication
- Powered by Node.js and Chrome Extensions API

## 💡 Future Ideas

- [ ] Support for other ports besides 3000
- [ ] Support for games using different package managers (yarn, pnpm)
- [ ] Safari extension support
- [ ] Windows and Linux support
- [ ] Built-in game library/favorites

---

Made with ❤️ for game developers

**Star ⭐ this repo if you find it useful!**
