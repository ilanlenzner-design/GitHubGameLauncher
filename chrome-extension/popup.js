document.addEventListener('DOMContentLoaded', async () => {
  const statusDiv = document.getElementById('status');
  const launchBtn = document.getElementById('launchBtn');
  const repoUrlDiv = document.getElementById('repoUrl');

  // Get current tab URL
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  const url = tab.url;

  // Check if it's a GitHub repository page
  if (url && url.includes('github.com') && url.split('/').length >= 5) {
    const repoUrl = url.split('?')[0].split('#')[0]; // Clean URL

    statusDiv.textContent = '✅ Repository detected!';
    statusDiv.className = 'success';
    repoUrlDiv.textContent = repoUrl;
    launchBtn.disabled = false;

    launchBtn.addEventListener('click', () => {
      launchBtn.disabled = true;
      launchBtn.textContent = 'Launching...';

      // Send message to background script to launch the game
      chrome.runtime.sendMessage(
        { action: 'launchGame', url: repoUrl },
        (response) => {
          if (response && response.success) {
            statusDiv.textContent = '🚀 Game is launching! Check Terminal...';
            statusDiv.className = 'success';
            launchBtn.textContent = 'Launched!';
            setTimeout(() => window.close(), 2000);
          } else {
            statusDiv.textContent = '❌ Error: ' + (response?.error || 'Unknown error');
            statusDiv.className = 'error';
            launchBtn.textContent = 'Launch Game';
            launchBtn.disabled = false;
          }
        }
      );
    });
  } else {
    statusDiv.textContent = '⚠️ Not a GitHub repository page';
    statusDiv.className = 'error';
    repoUrlDiv.textContent = 'Please navigate to a GitHub repository';
  }
});
