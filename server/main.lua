-- EvanderVoxel Server - Main Entry Point
local socket = require("socket")
local json = require("dkjson")

-- Server configuration
local HOST = "localhost"
local PORT = 8080
local MAX_PLAYERS = 5

-- Game state
local players = {}
local world_chunks = {}

-- Simple WebSocket handshake
local function websocket_handshake(client)
    local request = client:receive()
    if not request then return false end-- EvanderVoxel Server Main Entry Point
local socket = require("socket")
local json = require("lib.json")
local World = require("modules.world")
local Network = require("modules.network")

local Server = {}
Server.__index = Server

function Server:new()
    local self = setmetatable({}, Server)
    self.host = "localhost"
    self.port = 8080
    self.clients = {}
    self.world = World:new()
    self.network = Network:new(self)
    self.running = false
    return self
end

function Server:start()
    self.server = socket.bind(self.host, self.port)
    if not self.server then
        print("Failed to bind to " .. self.host .. ":" .. self.port)
        return false
    end
    
    self.server:settimeout(0) -- Non-blocking
    self.running = true
    
    print("EvanderVoxel server starting on " .. self.host .. ":" .. self.port)
    print("Press Ctrl+C to stop")
    
    self:gameLoop()
    return true
end

function Server:gameLoop()
    while self.running do
        -- Accept new connections
        local client = self.server:accept()
        if client then
            client:settimeout(0)
            table.insert(self.clients, {
                socket = client,
                id = #self.clients + 1,
                position = {x = 0, y = 50, z = 0}
            })
            print("New client connected: " .. #self.clients)
        end
        
        -- Handle existing clients
        for i = #self.clients, 1, -1 do
            local client = self.clients[i]
            local data, err = client.socket:receive()
            
            if data then
                self.network:handleMessage(client, data)
            elseif err == "closed" then
                print("Client " .. client.id .. " disconnected")
                client.socket:close()
                table.remove(self.clients, i)
            end
        end
        
        -- Update world
        self.world:update()
        
        -- Small delay to prevent CPU spinning
        socket.sleep(0.016) -- ~60 FPS
    end
end

function Server:broadcast(message)
    local jsonData = json.encode(message)
    for _, client in ipairs(self.clients) do
        client.socket:send(jsonData .. "\n")
    end
end

function Server:stop()
    self.running = false
    if self.server then
        self.server:close()
    end
    for _, client in ipairs(self.clients) do
        client.socket:close()
    end
    print("Server stopped")
end

-- Start the server
local server = Server:new()
server:start()
    
    -- Extract WebSocket key
    local key = request:match("Sec%-WebSocket%-Key: ([^\r\n]+)")
    if not key then return false end
    
    -- WebSocket magic string
    local magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    local accept = require("lib.websocket").sha1_base64(key .. magic)
    
    -- Send handshake response
    local response = "HTTP/1.1 101 Switching Protocols\r\n" ..
                    "Upgrade: websocket\r\n" ..
                    "Connection: Upgrade\r\n" ..
                    "Sec-WebSocket-Accept: " .. accept .. "\r\n\r\n"
    
    client:send(response)
    return true
end

-- Send message to client
local function send_message(client, message)
    local data = json.encode(message)
    local frame = require("lib.websocket").create_frame(data)
    client:send(frame)
end

-- Broadcast message to all players
local function broadcast_message(message, exclude_client)
    for client, player in pairs(players) do
        if client ~= exclude_client then
            send_message(client, message)
        end
    end
end

-- Handle client messages
local function handle_message(client, message)
    local data = json.decode(message)
    if not data then return end
    
    print("Received:", data.type)
    
    if data.type == "player_join" then
        players[client] = {
            position = data.position or {x = 0, y = 40, z = 0},
            id = #players + 1
        }
        print("Player joined. Total players:", #players)
        
    elseif data.type == "block_update" then
        -- Update world state
        local chunk_key = math.floor(data.x / 16) .. "," .. math.floor(data.z / 16)
        if not world_chunks[chunk_key] then
            world_chunks[chunk_key] = {}
        end
        
        local block_key = data.x .. "," .. data.y .. "," .. data.z
        world_chunks[chunk_key][block_key] = data.block_type
        
        -- Broadcast to other players
        broadcast_message({
            type = "block_update",
            x = data.x,
            y = data.y,
            z = data.z,
            block_type = data.block_type
        }, client)
        
        print("Block updated at", data.x, data.y, data.z, "->", data.block_type)
    end
end

-- Main server loop
local function run_server()
    local server = socket.bind(HOST, PORT)
    if not server then
        print("Failed to bind to " .. HOST .. ":" .. PORT)
        return
    end
    
    server:settimeout(0) -- Non-blocking
    print("EvanderVoxel server running on " .. HOST .. ":" .. PORT)
    print("Waiting for players...")
    
    while true do
        -- Accept new connections
        local client = server:accept()
        if client then
            if #players < MAX_PLAYERS then
                client:settimeout(0)
                if websocket_handshake(client) then
                    print("New player connected")
                else
                    client:close()
                end
            else
                client:close()
                print("Server full, rejected connection")
            end
        end
        
        -- Process existing connections
        local to_remove = {}
        for client, player in pairs(players) do
            local message, err = client:receive()
            if message then
                local decoded = require("lib.websocket").decode_frame(message)
                if decoded then
                    handle_message(client, decoded)
                end
            elseif err == "closed" then
                table.insert(to_remove, client)
            end
        end
        
        -- Remove disconnected players
        for _, client in ipairs(to_remove) do
            players[client] = nil
            client:close()
            print("Player disconnected. Total players:", #players)
        end
        
        -- Small delay to prevent busy waiting
        socket.sleep(0.01)
    end
end

-- Start server
run_server()