#!/usr/bin/env node

const http = require('http');
const { exec } = require('child_process');
const url = require('url');

const PORT = 3001;
const GAME_PORT = 3000;

const server = http.createServer((req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    const parsedUrl = url.parse(req.url, true);

    if (parsedUrl.pathname === '/launch') {
        const gameUrl = parsedUrl.query.url;

        if (!gameUrl) {
            res.writeHead(400);
            res.end('Missing URL parameter');
            return;
        }

        console.log(`\n🎮 Launching game: ${gameUrl}`);

        // Execute the run-github-game script in a new Terminal window
        const command = `osascript -e 'tell application "Terminal" to do script "cd ~ && ~/run-github-game.sh '${gameUrl}'"'`;

        exec(command, (error) => {
            if (error) {
                console.error(`Error: ${error.message}`);
                res.writeHead(500);
                res.end(`Error launching game: ${error.message}`);
                return;
            }

            res.writeHead(200);
            res.end('✅ Game is launching! Check Terminal...');
        });
    } else if (parsedUrl.pathname === '/check') {
        // Check if game server is ready on port 3000
        const checkReq = http.get(`http://localhost:${GAME_PORT}`, (checkRes) => {
            if (checkRes.statusCode === 200) {
                res.writeHead(200);
                res.end('ready');
            } else {
                res.writeHead(503);
                res.end('not ready');
            }
        });

        checkReq.on('error', () => {
            res.writeHead(503);
            res.end('not ready');
        });
    } else if (parsedUrl.pathname === '/') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
            <html>
                <head><title>Play Game Launcher Service</title></head>
                <body style="font-family: sans-serif; max-width: 600px; margin: 50px auto; padding: 20px;">
                    <h1>🎮 Play Game Launcher Service</h1>
                    <p>✅ Service is running on port ${PORT}</p>
                    <p>Use the Chrome extension on GitHub pages to launch games!</p>
                    <p><strong>Status:</strong> Ready</p>
                </body>
            </html>
        `);
    } else {
        res.writeHead(404);
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log(`\n🚀 Play Game Launcher Service running on http://localhost:${PORT}`);
    console.log(`\n📖 Instructions:`);
    console.log(`   1. Install the Chrome extension from ~/game-launcher-extension`);
    console.log(`   2. Go to any GitHub repo and click the extension`);
    console.log(`   3. Click "Launch Game"`);
    console.log(`\n✋ Press Ctrl+C to stop the service\n`);
});
