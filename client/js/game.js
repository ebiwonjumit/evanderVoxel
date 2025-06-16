// Main game initialization and loop
let scene, camera, renderer;
const RENDER_DISTANCE = 50;

function init() {
    // Initialize Three.js
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x87CEEB);
    document.body.appendChild(renderer.domElement);

    // Lighting
    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(50, 50, 50);
    scene.add(directionalLight);

    // Set initial camera position
    camera.position.set(0, 40, 0);
    
    // Setup controls
    setupControls();
    
    // Initial world render
    renderWorld();
    
    // Start game loop
    animate();
    
    console.log('EvanderVoxel initialized!');
}

function renderWorld() {
    // Clear existing blocks
    const blocksToRemove = [];
    scene.children.forEach(child => {
        if (child.userData.isBlock) {
            blocksToRemove.push(child);
        }
    });
    blocksToRemove.forEach(block => scene.remove(block));

    // Render visible blocks around player
    const playerPos = camera.position;
    
    for (let x = Math.floor(playerPos.x - RENDER_DISTANCE); x < playerPos.x + RENDER_DISTANCE; x++) {
        for (let z = Math.floor(playerPos.z - RENDER_DISTANCE); z < playerPos.z + RENDER_DISTANCE; z++) {
            for (let y = 0; y < WORLD_HEIGHT; y++) {
                const blockType = getBlock(x, y, z);
                if (blockType !== BLOCKS.AIR && isBlockExposed(x, y, z)) {
                    const mesh = createBlockMesh(blockType);
                    if (mesh) {
                        mesh.position.set(x, y, z);
                        scene.add(mesh);
                    }
                }
            }
        }
    }
}

function animate() {
    requestAnimationFrame(animate);
    
    updatePlayer();
    
    // Re-render world occasionally for new chunks
    if (Math.random() < 0.01) {
        renderWorld();
    }
    
    renderer.render(scene, camera);
}

// Handle window resize
window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});

// Initialize when page loads
window.addEventListener('load', init);