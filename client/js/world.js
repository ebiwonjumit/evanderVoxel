// World generation and management
const world = {};
const CHUNK_SIZE = 16;
const WORLD_HEIGHT = 64;

// Simple noise function for terrain generation
function noise(x, z) {
    const n = Math.sin(x * 0.02) * Math.cos(z * 0.02) * 10 +
             Math.sin(x * 0.05) * Math.cos(z * 0.05) * 5 +
             Math.sin(x * 0.1) * Math.cos(z * 0.1) * 2;
    return Math.floor(n) + 32;
}

// Generate a chunk of terrain
function generateChunk(chunkX, chunkZ) {
    const chunk = {};
    for (let x = 0; x < CHUNK_SIZE; x++) {
        for (let z = 0; z < CHUNK_SIZE; z++) {
            const worldX = chunkX * CHUNK_SIZE + x;
            const worldZ = chunkZ * CHUNK_SIZE + z;
            const height = noise(worldX, worldZ);
            
            for (let y = 0; y < WORLD_HEIGHT; y++) {
                const key = `${x},${y},${z}`;
                if (y < height - 3) {
                    chunk[key] = BLOCKS.STONE;
                } else if (y < height - 1) {
                    chunk[key] = BLOCKS.DIRT;
                } else if (y < height) {
                    chunk[key] = BLOCKS.GRASS;
                } else {
                    chunk[key] = BLOCKS.AIR;
                }
            }
        }
    }
    return chunk;
}

function getChunkKey(chunkX, chunkZ) {
    return `${chunkX},${chunkZ}`;
}

function getBlock(x, y, z) {
    const chunkX = Math.floor(x / CHUNK_SIZE);
    const chunkZ = Math.floor(z / CHUNK_SIZE);
    const chunkKey = getChunkKey(chunkX, chunkZ);
    
    if (!world[chunkKey]) {
        world[chunkKey] = generateChunk(chunkX, chunkZ);
    }
    
    const localX = x - chunkX * CHUNK_SIZE;
    const localZ = z - chunkZ * CHUNK_SIZE;
    const blockKey = `${localX},${y},${localZ}`;
    
    return world[chunkKey][blockKey] || BLOCKS.AIR;
}

function setBlock(x, y, z, type) {
    const chunkX = Math.floor(x / CHUNK_SIZE);
    const chunkZ = Math.floor(z / CHUNK_SIZE);
    const chunkKey = getChunkKey(chunkX, chunkZ);
    
    if (!world[chunkKey]) {
        world[chunkKey] = generateChunk(chunkX, chunkZ);
    }
    
    const localX = x - chunkX * CHUNK_SIZE;
    const localZ = z - chunkZ * CHUNK_SIZE;
    const blockKey = `${localX},${y},${localZ}`;
    
    world[chunkKey][blockKey] = type;
    renderWorld();
    
    // Send to server if connected
    if (typeof sendBlockUpdate === 'function') {
        sendBlockUpdate(x, y, z, type);
    }
}

// Check if block is exposed (has at least one air neighbor)
function isBlockExposed(x, y, z) {
    return (
        getBlock(x + 1, y, z) === BLOCKS.AIR ||
        getBlock(x - 1, y, z) === BLOCKS.AIR ||
        getBlock(x, y + 1, z) === BLOCKS.AIR ||
        getBlock(x, y - 1, z) === BLOCKS.AIR ||
        getBlock(x, y, z + 1) === BLOCKS.AIR ||
        getBlock(x, y, z - 1) === BLOCKS.AIR
    );
}