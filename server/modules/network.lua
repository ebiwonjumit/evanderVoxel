-- Network Message Handling
local json = require("lib.json")

local Network = {}
Network.__index = Network

function Network:new(server)
    local self = setmetatable({}, Network)
    self.server = server
    self.messageHandlers = {
        ["join"] = self.handleJoin,
        ["move"] = self.handleMove,
        ["block_place"] = self.handleBlockPlace,
        ["block_break"] = self.handleBlockBreak,
        ["chat"] = self.handleChat
    }
    return self
end

function Network:handleMessage(client, data)
    local success, message = pcall(json.decode, data)
    if not success then
        print("Invalid JSON from client " .. client.id)
        return
    end
    
    local handler = self.messageHandlers[message.type]
    if handler then
        handler(self, client, message)
    else
        print("Unknown message type: " .. (message.type or "nil"))
    end
end

function Network:handleJoin(client, message)
    print("Player " .. client.id .. " joined the game")
    
    -- Send world data to client
    local response = {
        type = "world_data",
        chunks = {}
    }
    
    -- Send nearby chunks
    for x = -1, 1 do
        for z = -1, 1 do
            local chunkData = self.server.world:getChunkData(x, z)
            if chunkData then
                table.insert(response.chunks, chunkData)
            end
        end
    end
    
    self:sendToClient(client, response)
    
    -- Broadcast new player to others
    self.server:broadcast({
        type = "player_join",
        playerId = client.id,
        position = client.position
    })
end

function Network:handleMove(client, message)
    if message.position then
        client.position = message.position
        
        -- Broadcast position to other clients
        self.server:broadcast({
            type = "player_move",
            playerId = client.id,
            position = client.position
        })
    end
end

function Network:handleBlockPlace(client, message)
    if message.x and message.y and message.z and message.blockType then
        self.server.world:setBlock(message.x, message.y, message.z, message.blockType)
        
        -- Broadcast block change to all clients
        self.server:broadcast({
            type = "block_change",
            x = message.x,
            y = message.y,
            z = message.z,
            blockType = message.blockType,
            playerId = client.id
        })
    end
end

function Network:handleBlockBreak(client, message)
    if message.x and message.y and message.z then
        self.server.world:setBlock(message.x, message.y, message.z, 0) -- 0 = Air
        
        -- Broadcast block change to all clients
        self.server:broadcast({
            type = "block_change",
            x = message.x,
            y = message.y,
            z = message.z,
            blockType = 0,
            playerId = client.id
        })
    end
end

function Network:handleChat(client, message)
    if message.text then
        -- Broadcast chat message to all clients
        self.server:broadcast({
            type = "chat",
            playerId = client.id,
            text = message.text,
            timestamp = os.time()
        })
    end
end

function Network:sendToClient(client, message)
    local jsonData = json.encode(message)
    client.socket:send(jsonData .. "\n")
end

return Network