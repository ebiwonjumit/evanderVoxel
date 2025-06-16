-- World State Management
local World = {}
World.__index = World

function World:new()
    local self = setmetatable({}, World)
    self.chunks = {}
    self.chunkSize = 16
    self.worldHeight = 64
    self:generateInitialWorld()
    return self
end

function World:generateInitialWorld()
    -- Generate a simple 3x3 grid of chunks around origin
    for x = -1, 1 do
        for z = -1, 1 do
            self:generateChunk(x, z)
        end
    end
    print("EvanderMania generated")
end

function World:generateChunk(chunkX, chunkZ)
    local chunk = {
        x = chunkX,
        z = chunkZ,
        blocks = {}
    }
    
    -- Simple terrain generation
    for x = 0, self.chunkSize - 1 do
        chunk.blocks[x] = {}
        for z = 0, self.chunkSize - 1 do
            chunk.blocks[x][z] = {}
            
            -- Create simple terrain
            local worldX = chunkX * self.chunkSize + x
            local worldZ = chunkZ * self.chunkSize + z
            local height = self:getTerrainHeight(worldX, worldZ)
            
            for y = 0, self.worldHeight - 1 do
                if y < height - 3 then
                    chunk.blocks[x][z][y] = 3 -- Stone
                elseif y < height - 1 then
                    chunk.blocks[x][z][y] = 2 -- Dirt
                elseif y < height then
                    chunk.blocks[x][z][y] = 1 -- Grass
                else
                    chunk.blocks[x][z][y] = 0 -- Air
                end
            end
        end
    end
    
    local chunkKey = chunkX .. "," .. chunkZ
    self.chunks[chunkKey] = chunk
end

function World:getTerrainHeight(x, z)
    -- Simple sine wave terrain
    local height = 32 + math.sin(x * 0.1) * 8 + math.cos(z * 0.1) * 8
    return math.floor(height)
end

function World:getBlock(x, y, z)
    local chunkX = math.floor(x / self.chunkSize)
    local chunkZ = math.floor(z / self.chunkSize)
    local chunkKey = chunkX .. "," .. chunkZ
    
    local chunk = self.chunks[chunkKey]
    if not chunk then
        return 0 -- Air if chunk doesn't exist
    end
    
    local localX = x % self.chunkSize
    local localZ = z % self.chunkSize
    
    if chunk.blocks[localX] and chunk.blocks[localX][localZ] then
        return chunk.blocks[localX][localZ][y] or 0
    end
    
    return 0
end

function World:setBlock(x, y, z, blockType)
    local chunkX = math.floor(x / self.chunkSize)
    local chunkZ = math.floor(z / self.chunkSize)
    local chunkKey = chunkX .. "," .. chunkZ
    
    local chunk = self.chunks[chunkKey]
    if not chunk then
        self:generateChunk(chunkX, chunkZ)
        chunk = self.chunks[chunkKey]
    end
    
    local localX = x % self.chunkSize
    local localZ = z % self.chunkSize
    
    if not chunk.blocks[localX] then
        chunk.blocks[localX] = {}
    end
    if not chunk.blocks[localX][localZ] then
        chunk.blocks[localX][localZ] = {}
    end
    
    chunk.blocks[localX][localZ][y] = blockType
end

function World:getChunkData(chunkX, chunkZ)
    local chunkKey = chunkX .. "," .. chunkZ
    return self.chunks[chunkKey]
end

function World:update()
    -- World update logic (future: entity updates, physics, etc.)
end

return World