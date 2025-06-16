// Player controls and movement
let keys = {};
let mouseX = 0, mouseY = 0;
const MOVE_SPEED = 0.2;

function setupControls() {
    document.addEventListener('keydown', (e) => {
        keys[e.code] = true;
        
        // Block type selection
        if (e.code >= 'Digit1' && e.code <= 'Digit4') {
            const blockType = parseInt(e.code.slice(-1));
            setCurrentBlockType(blockType);
        }
    });
    
    document.addEventListener('keyup', (e) => {
        keys[e.code] = false;
    });
    
    document.addEventListener('mousemove', (e) => {
        if (document.pointerLockElement) {
            mouseX += e.movementX * 0.002;
            mouseY += e.movementY * 0.002;
            mouseY = Math.max(-Math.PI / 2, Math.min(Math.PI / 2, mouseY));
        }
    });
    
    document.addEventListener('click', () => {
        if (!document.pointerLockElement) {
            renderer.domElement.requestPointerLock();
        } else {
            // Mine block
            const target = getTargetBlock();
            if (target) {
                const pos = target.position;
                setBlock(pos.x, pos.y, pos.z, BLOCKS.AIR);
            }
        }
    });
    
    document.addEventListener('contextmenu', (e) => {
        e.preventDefault();
        if (document.pointerLockElement) {
            // Place block
            const target = getTargetBlock();
            if (target) {
                const pos = target.position.clone().add(target.normal);
                setBlock(pos.x, pos.y, pos.z, getCurrentBlockType());
            }
        }
    });
}

function updatePlayer() {
    // Movement
    const forward = new THREE.Vector3(0, 0, -1).applyQuaternion(camera.quaternion);
    const right = new THREE.Vector3(1, 0, 0).applyQuaternion(camera.quaternion);
    
    if (keys['KeyW']) camera.position.addScaledVector(forward, MOVE_SPEED);
    if (keys['KeyS']) camera.position.addScaledVector(forward, -MOVE_SPEED);
    if (keys['KeyA']) camera.position.addScaledVector(right, -MOVE_SPEED);
    if (keys['KeyD']) camera.position.addScaledVector(right, MOVE_SPEED);
    if (keys['Space']) camera.position.y += MOVE_SPEED;
    if (keys['ShiftLeft']) camera.position.y -= MOVE_SPEED;
    
    // Mouse look
    camera.rotation.order = 'YXZ';
    camera.rotation.y = -mouseX;
    camera.rotation.x = -mouseY;
    
    // Update UI
    const pos = camera.position;
    document.getElementById('coords').textContent = 
        `Position: ${Math.floor(pos.x)}, ${Math.floor(pos.y)}, ${Math.floor(pos.z)}`;
}

// Raycasting for block interaction
function getTargetBlock() {
    const raycaster = new THREE.Raycaster();
    raycaster.setFromCamera(new THREE.Vector2(0, 0), camera);
    
    const intersects = raycaster.intersectObjects(
        scene.children.filter(obj => obj.userData.isBlock)
    );
    
    if (intersects.length > 0) {
        const intersect = intersects[0];
        const block = intersect.object;
        const face = intersect.face;
        
        return {
            position: block.position.clone(),
            normal: face.normal.clone(),
            point: intersect.point
        };
    }
    return null;
}