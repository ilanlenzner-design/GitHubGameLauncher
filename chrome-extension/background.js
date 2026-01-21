// Function to check if game server is ready
async function waitForGameServer(maxWaitTime = 60000) {
  const startTime = Date.now();
  const checkInterval = 2000; // Check every 2 seconds

  while (Date.now() - startTime < maxWaitTime) {
    try {
      const response = await fetch('http://localhost:3001/check');
      const status = await response.text();

      if (status === 'ready') {
        console.log('Game server is ready!');
        return true;
      }
    } catch (error) {
      // Server not ready yet, continue waiting
    }

    // Wait before next check
    await new Promise(resolve => setTimeout(resolve, checkInterval));
  }

  return false; // Timeout
}

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'launchGame') {
    const gameUrl = request.url;

    // Call the local service to launch the game
    fetch(`http://localhost:3001/launch?url=${encodeURIComponent(gameUrl)}`)
      .then(response => response.text())
      .then(async message => {
        console.log('Game launcher response:', message);

        // Wait for the game server to be ready
        console.log('Waiting for webpack to compile...');
        const isReady = await waitForGameServer();

        if (isReady) {
          // Open the game page once webpack is done
          chrome.tabs.create({ url: 'http://localhost:3000' });
          sendResponse({ success: true, message: message });
        } else {
          sendResponse({ success: false, error: 'Timeout waiting for game server' });
        }
      })
      .catch(error => {
        console.error('Error launching game:', error);
        sendResponse({ success: false, error: error.message });
      });

    // Return true to indicate we'll send a response asynchronously
    return true;
  }
});
