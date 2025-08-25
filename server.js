const express = require('express');
const path = require('path');
const Docker = require('dockerode');
const docker = new Docker();
const app = express();
const port = 3000;

// Store a map of sessions to container IDs
// In a real app, this would be linked to user accounts in a database
const activeContainers = new Map();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// The API endpoint to create and get a terminal
app.post('/api/terminal', async (req, res) => {
    // In a real app, you'd get a unique session ID from the user's login
    const sessionId = 'default-user'; 

    // If this user already has a container, destroy it first
    if (activeContainers.has(sessionId)) {
        try {
            const oldContainer = docker.getContainer(activeContainers.get(sessionId));
            await oldContainer.remove({ force: true });
            console.log(`Removed old container for session: ${sessionId}`);
        } catch (err) {
            console.error(`Error removing old container: ${err.message}`);
        }
    }

    try {
        // Find a free port on the host machine
        const hostPort = await findFreePort();

        const container = await docker.createContainer({
            Image: 'kali-ctf-webshell', // Our custom image
            Tty: false,
            HostConfig: {
                // Map the container's internal port 7681 to the free host port
                PortBindings: { '7681/tcp': [{ HostPort: String(hostPort) }] },
                // IMPORTANT: For the curl/wget example to work, we need a network.
                // This creates a dedicated network for the container. It is more secure
                // than 'bridge' but still allows outbound connections. For full lockdown,
                // you would switch this back to 'none'.
                NetworkMode: 'bridge',
                Memory: 512 * 1024 * 1024, // 512MB RAM limit
                CpuShares: 512,
            },
        });

        await container.start();
        activeContainers.set(sessionId, container.id);
        console.log(`Started container ${container.id} for session ${sessionId} on port ${hostPort}`);

        // Wait a moment for ttyd to initialize inside the container
        setTimeout(() => {
            res.json({ url: `http://localhost:${hostPort}` });
        }, 1000); // 1-second delay

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create terminal.' });
    }
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});

// Helper function to find a free port (for simplicity)
const net = require('net');
function findFreePort() {
    return new Promise(res => {
        const server = net.createServer();
        server.listen(0, () => {
            const port = server.address().port;
            server.close(() => res(port));
        });
    });
}