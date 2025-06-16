// Block definitions and management
const BLOCKS = {
    AIR: 0,
    GRASS: 1,
    DIRT: 2,
    STONE: 3,
    WATER: 4
};

const blockTypes = {
    [BLOCKS.AIR]: { color: 0x000000, name: 'Air', solid: false },
    [BLOCKS.GRASS]: { color: 0x4CAF50, name: 'Grass', solid: true },
    [BLOCKS.DIRT]: { color: 0x8D6E63, name: 'Dirt', solid: true },
    [BLOCKS.STONE]: { color: 0x9E9E9E, name: 'Stone', solid: true },
    [BLOCKS.WATER]: { color: 0x2196F3, name: 'Water', solid: false }
};

let currentBlockType = BLOCKS.GRASS;

function getBlockInfo(type) {
    return blockTypes[type] || blockTypes[BLOCKS.AIR];
}

function setCurrentBlockType(type) {
    if (blockTypes[type]) {
        currentBlockType = type;
        document.getElementById('blockType').textContent = blockTypes[type].name;
        return true;
    }
    return false;
}

function getCurrentBlockType() {
    return currentBlockType;
}

// Create block mesh
function createBlockMesh(blockType) {
    const info = getBlockInfo(blockType);
    if (!info.solid) return null;
    
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const material = new THREE.MeshLambertMaterial({ 
        color: info.color 
    });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.userData.isBlock = true;
    mesh.userData.blockType = blockType;
    
    return mesh;
}