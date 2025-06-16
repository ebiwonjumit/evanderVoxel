-- Simple WebSocket implementation
local bit = require("bit")
local crypto = require("crypto")

local websocket = {}

-- Base64 encode
function websocket.base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- SHA1 + Base64 for WebSocket handshake
function websocket.sha1_base64(data)
    local hash = crypto.digest("sha1", data, true)
    return websocket.base64_encode(hash)
end

-- Create WebSocket frame (simplified for text)
function websocket.create_frame(data)
    local len = #data
    local frame = ""
    
    -- FIN + TEXT opcode
    frame = frame .. string.char(0x81)
    
    -- Length
    if len < 126 then
        frame = frame .. string.char(len)
    elseif len < 65536 then
        frame = frame .. string.char(126)
        frame = frame .. string.char(bit.rshift(len, 8))
        frame = frame .. string.char(bit.band(len, 0xFF))
    else
        -- For larger payloads (not implemented for simplicity)
        error("Payload too large")
    end
    
    -- Payload
    frame = frame .. data
    
    return frame
end

-- Decode WebSocket frame (simplified)
function websocket.decode_frame(frame)
    if #frame < 2 then return nil end
    
    local pos = 1
    local first_byte = string.byte(frame, pos)
    pos = pos + 1
    
    local second_byte = string.byte(frame, pos)
    pos = pos + 1
    
    local masked = bit.band(second_byte, 0x80) ~= 0
    local payload_len = bit.band(second_byte, 0x7F)
    
    -- Extended length
    if payload_len == 126 then
        if #frame < pos + 1 then return nil end
        payload_len = bit.lshift(string.byte(frame, pos), 8) + string.byte(frame, pos + 1)
        pos = pos + 2
    elseif payload_len == 127 then
        -- 64-bit length not implemented for simplicity
        return nil
    end
    
    -- Masking key
    local mask_key = ""
    if masked then
        if #frame < pos + 3 then return nil end
        mask_key = frame:sub(pos, pos + 3)
        pos = pos + 4
    end
    
    -- Payload
    if #frame < pos + payload_len - 1 then return nil end
    local payload = frame:sub(pos, pos + payload_len - 1)
    
    -- Unmask if necessary
    if masked then
        local unmasked = ""
        for i = 1, #payload do
            local mask_byte = string.byte(mask_key, ((i - 1) % 4) + 1)
            local payload_byte = string.byte(