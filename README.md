# EvanderVoxel 🎮

A multiplayer voxel-based sandbox game built with Three.js and Lua. Think Minecraft meets custom creativity - build, explore, and play together in a procedurally generated world!

## 🎯 Project Goals

This is a summer coding project designed for learning game development, 3D graphics, networking, and collaborative programming. By the end of summer, we'll have a fully functional multiplayer voxel game with custom features.

## 🚀 Quick Start

### Prerequisites
- **Lua** (5.1 or higher) - for the server
- **Modern web browser** - for the client
- **Basic HTTP server** (Python, Node.js, or similar) - for development

### Installation & Setup

1. **Clone and setup the project:**
   ```bash
   git clone repo
   cd evanderVoxel
   
   # Create directory structure
   mkdir -p client/{js,css,assets/{textures,sounds}}
   mkdir -p server/{lib,modules,data/{worlds}}
   mkdir -p tools docs
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x tools/start-server.sh
   chmod +x tools/start-client.sh
   ```

3. **Start the server:**
   ```bash
   ./tools/start-server.sh
   ```

4. **Start the client (in a new terminal):**
   ```bash
   ./tools/start-client.sh
   # Or simply open client/index.html in your browser
   ```

5. **Play!** 
   - Open multiple browser tabs to test multiplayer
   - Use WASD to move, mouse to look around
   - Click to place/break blocks

## 🏗️ Architecture

- **Frontend**: Three.js (WebGL) for 3D rendering and game client
- **Backend**: Lua server with TCP/WebSocket communication
- **Networking**: Real-time multiplayer with client-server architecture
- **World**: Procedural chunk-based generation with persistence

```
evandervoxel/
├── client/          # Three.js frontend
├── server/          # Lua backend
├── tools/           # Development scripts
└── docs/           # Documentation
```

## 🎮 Current Features

### ✅ Implemented
- [x] Basic 3D world rendering
- [x] Player movement and camera controls
- [x] Simple terrain generation
- [x] Multi-client server architecture
- [x] Basic networking protocol

### 🚧 In Progress
- [ ] WebSocket integration
- [ ] Block placement/destruction
- [ ] Client-side world rendering optimization

## 🗓️ Summer Development Roadmap

### Phase 1: Core Foundation (Weeks 1-2)
**Goal**: Get the basic game running with multiplayer

**Week 1: Basic World**
- [ ] Complete client-side world rendering
- [ ] Implement chunk loading/unloading
- [ ] Add basic block types (grass, dirt, stone, wood)
- [ ] Create simple terrain generation with hills and valleys

**Week 2: Player Interaction**
- [ ] Implement block placing and breaking
- [ ] Add player collision detection
- [ ] Create basic inventory system
- [ ] Implement proper WebSocket communication

### Phase 2: Game Mechanics (Weeks 3-4)
**Goal**: Make it feel like a real game

**Week 3: Enhanced Gameplay**
- [ ] Add gravity and physics
- [ ] Implement different block types with properties
- [ ] Create crafting system basics
- [ ] Add day/night cycle with lighting

**Week 4: World Building**
- [ ] Improve terrain generation (caves, mountains, rivers)
- [ ] Add trees and vegetation
- [ ] Implement world saving/loading
- [ ] Create respawn and spawn point system

### Phase 3: Customization & Polish (Weeks 5-6)
**Goal**: Add unique features and polish

**Week 5: Custom Features**
- [ ] Design and implement unique block types
- [ ] Add particle effects (breaking blocks, explosions)
- [ ] Create custom tools and weapons
- [ ] Implement mob/entity system

**Week 6: Polish & Performance**
- [ ] Add sound effects and music
- [ ] Optimize rendering performance
- [ ] Improve UI/UX design
- [ ] Add settings and configuration options

### Phase 4: Advanced Features (Weeks 7-8)
**Goal**: Add advanced systems and final touches

**Week 7: Advanced Systems**
- [ ] Implement redstone-like logic blocks
- [ ] Add weather system
- [ ] Create teleportation/portal system
- [ ] Build admin commands and creative mode

**Week 8: Final Polish**
- [ ] Add achievements system
- [ ] Create game tutorials
- [ ] Build launcher/menu system
- [ ] Final bug fixes and optimization

<!-- ## 🎯 Custom Feature Ideas

Brainstorm and implement your own unique features:

### Potential Custom Features
- **Magic Blocks**: Blocks with special properties (teleporters, gravity blocks)
- **Mini-Games**: Built-in parkour courses, puzzles, or challenges
- **Custom Mobs**: Friendly creatures, pets, or challenging enemies
- **Weather Effects**: Rain, snow, storms that affect gameplay
- **Vehicle System**: Boats, minecarts, or flying machines
- **Farming System**: Crops, animals, and food mechanics
- **Economy System**: Trading, shops, and currency
- **Territory System**: Claim and protect your builds
- **Seasons**: World changes over time with different seasons

### Technical Challenges
- **Shaders**: Custom visual effects and lighting
- **Procedural Structures**: Automatic building generation
- **AI Systems**: Smart NPCs or automated helpers
- **Physics Engine**: Advanced physics for complex interactions
- **Modding API**: Allow external modifications

## 📚 Learning Objectives

By the end of this project, you'll have hands-on experience with:

- **3D Graphics**: Three.js, WebGL, lighting, textures, shaders
- **Game Development**: Game loops, physics, collision detection
- **Networking**: Client-server architecture, real-time communication
- **Data Structures**: Spatial data structures, chunk systems
- **Performance Optimization**: Frustum culling, LOD, batching
- **Software Architecture**: Modular design, separation of concerns
- **Version Control**: Git workflows, collaborative development -->


## 📖 Resources

### Documentation
- `docs/architecture.md` - System design and technical decisions
- `docs/protocol.md` - Network protocol specification
- `docs/development-log.md` - Daily progress and notes

### External Resources
- [Three.js Documentation](https://threejs.org/docs/)
- [Lua Programming Guide](https://www.lua.org/manual/5.4/)
- [Game Programming Patterns](https://gameprogrammingpatterns.com/)
- [Minecraft Wiki](https://minecraft.fandom.com/) - for inspiration

## 📝 Development Journal

Keep track of your daily progress in `docs/development-log.md`:
- What you learned
- Challenges you faced
- Solutions you discovered
- Ideas for future features

## 🎉 Milestones

**🏁 End of Summer Goals:**
- [ ] Fully functional multiplayer voxel game
- [ ] At least 5 unique custom features
- [ ] Polished UI and user experience  
- [ ] Comprehensive documentation
- [ ] Playable demo for friends and family

---
