// Network/WebSocket client
let socket = null;
let isConnected = false;

function connectToServer() {
    try {
        socket = new WebSocket('ws://localhost:8080');
        
        socket.onopen = () => {
            isConnected = true;
            updateConnectionStatus('Online', 'online');
            console.log('Connected to server');
            
            // Send initial player data
            sendMessage({
                type: 'player_join',
                position: {
                    x: camera.position.x,
                    y: camera.position.y,
                    z: camera.position.z
                }
            });
        };
        
        socket.onclose = () => {
            isConnected = false;
            updateConnectionStatus('Offline', 'offline');
            console.log('Disconnected from server');
        };
        
        socket.onerror = (error) => {
            isConnected = false;
            updateConnectionStatus('Error', 'offline');
            console.log('Connection error:', error);
        };
        
        socket.onmessage = (event) => {
            try {
                const message = JSON.parse(event.data);
                handleServerMessage(message);
            } catch (e) {
                console.error('Failed to parse server message:', e);
            }
        };
        
    } catch (error) {
        console.log('Failed to connect to server:', error);
        updateConnectionStatus('Server Offline', 'offline');
    }
}

function sendMessage(message) {
    if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify(message));
    }
}

function sendBlockUpdate(x, y, z, type) {
    sendMessage({
        type: 'block_update',
        x: x,
        y: y,
        z: z,
        block_type: type
    });
}

function handleServerMessage(message) {
    switch (message.type) {
        case 'block_update':
            // Update local world without re-rendering (to avoid conflicts)
            const chunkX = Math.floor(message.x / CHUNK_SIZE);
            const chunkZ = Math.floor(message.z / CHUNK_SIZE);
            const chunkKey = `${chunkX},${chunkZ}`;
            
            if (!world[chunkKey]) {
                world[chunkKey] = generateChunk(chunkX, chunkZ);
            }
            
            const localX = message.x - chunkX * CHUNK_SIZE;
            const localZ = message.z - chunkZ * CHUNK_SIZE;
            const blockKey = `${localX},${message.y},${localZ}`;
            
            world[chunkKey][blockKey] = message.block_type;
            renderWorld();
            break;
            
        case 'player_count':
            // Update player count in UI (for future use)
            break;
            
        default:
            console.log('Unknown message type:', message.type);
    }
}

function updateConnectionStatus(text, className) {
    const statusEl = document.getElementById('status');
    statusEl.textContent = text;
    statusEl.className = className;
}

// Try to connect when page loads
window.addEventListener('load', () => {
    setTimeout(connectToServer, 1000); // Give game time to initialize
});