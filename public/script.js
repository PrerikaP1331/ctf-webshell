document.addEventListener('DOMContentLoaded', () => {
    const toggleBtn = document.getElementById('webshell-toggle-btn');
    const resetBtn = document.getElementById('webshell-reset-btn');
    const container = document.getElementById('webshell-container');
    const iframe = document.getElementById('terminal-frame');
    let isTerminalLoaded = false;

    // Function to open the terminal
    async function openTerminal() {
        if (isTerminalLoaded) return; // Don't open if it's already loading/loaded

        console.log('Requesting new terminal...');
        isTerminalLoaded = true;
        iframe.src = ''; // Clear the old frame

        try {
            // Ask our backend for a new terminal URL
            const response = await fetch('/api/terminal', { method: 'POST' });
            const data = await response.json();

            if (data.url) {
                iframe.src = data.url;
            } else {
                console.error('Failed to get terminal URL:', data.error);
                isTerminalLoaded = false;
            }
        } catch (err) {
            console.error('Error fetching terminal:', err);
            isTerminalLoaded = false;
        }
    }

    // Event listener for the main toggle button
    toggleBtn.addEventListener('click', () => {
        container.classList.toggle('visible');
        // If we are opening the shell for the first time, load the terminal
        if (container.classList.contains('visible') && !isTerminalLoaded) {
            openTerminal();
        }
    });

    // Event listener for the reset button
    resetBtn.addEventListener('click', () => {
        console.log('Resetting terminal...');
        isTerminalLoaded = false; // Allow a new terminal to be loaded
        openTerminal(); // Request a new terminal
    });
});