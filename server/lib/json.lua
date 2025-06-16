-- Simple JSON library for Lua
-- This is a minimal implementation - you might want to use a more robust library

local json = {}

function json.encode(obj)
    local t = type(obj)
    if t == "nil" then
        return "null"
    elseif t == "boolean" then
        return obj and "true" or "false"
    elseif t == "number" then
        return tostring(obj)
    elseif t == "string" then
        return '"' .. obj:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
    elseif t == "table" then
        local isArray = true
        local maxIndex = 0
        for k, v in pairs(obj) do
            if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
                isArray = false
                break
            end
            maxIndex = math.max(maxIndex, k)
        end
        
        if isArray then
            local result = {}
            for i = 1, maxIndex do
                result[i] = json.encode(obj[i])
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            local result = {}
            for k, v in pairs(obj) do
                table.insert(result, json.encode(tostring(k)) .. ":" .. json.encode(v))
            end
            return "{" .. table.concat(result, ",") .. "}"
        end
    else
        error("Cannot encode " .. t)
    end
end

function json.decode(str)
    local pos = 1
    
    local function decode_value()
        local char = str:sub(pos, pos)
        if char == '"' then
            return decode_string()
        elseif char == '{' then
            return decode_object()
        elseif char == '[' then
            return decode_array()
        elseif char == 't' then
            pos = pos + 4
            return true
        elseif char == 'f' then
            pos = pos + 5
            return false
        elseif char == 'n' then
            pos = pos + 4
            return nil
        else
            return decode_number()
        end
    end
    
    local function decode_string()
        pos = pos + 1 -- skip opening quote
        local start = pos
        while pos <= #str do
            local char = str:sub(pos, pos)
            if char == '"' then
                local result = str:sub(start, pos - 1)
                pos = pos + 1
                return result
            elseif char == '\\' then
                pos = pos + 2 -- skip escaped character
            else
                pos = pos + 1
            end
        end
        error("Unterminated string")
    end
    
    local function decode_number()
        local start = pos
        while pos <= #str and str:sub(pos, pos):match('[%d%.%-+eE]') do
            pos = pos + 1
        end
        return tonumber(str:sub(start, pos - 1))
    end
    
    local function decode_object()
        pos = pos + 1 -- skip opening brace
        local obj = {}
        
        while pos <= #str do
            local char = str:sub(pos, pos)
            if char == '}' then
                pos = pos + 1
                return obj
            elseif char == '"' then
                local key = decode_string()
                -- Skip whitespace and colon
                while pos <= #str and str:sub(pos, pos):match('[%s:]') do
                    pos = pos + 1
                end
                local value = decode_value()
                obj[key] = value
                -- Skip whitespace and comma
                while pos <= #str and str:sub(pos, pos):match('[%s,]') do
                    pos = pos + 1
                end
            else
                pos = pos + 1
            end
        end
        error("Unterminated object")
    end
    
    local function decode_array()
        pos = pos + 1 -- skip opening bracket
        local arr = {}
        local index = 1
        
        while pos <= #str do
            local char = str:sub(pos, pos)
            if char == ']' then
                pos = pos + 1
                return arr
            elseif not char:match('%s') then
                arr[index] = decode_value()
                index = index + 1
                -- Skip whitespace and comma
                while pos <= #str and str:sub(pos, pos):match('[%s,]') do
                    pos = pos + 1
                end
            else
                pos = pos + 1
            end
        end
        error("Unterminated array")
    end
    
    return decode_value()
end

return json