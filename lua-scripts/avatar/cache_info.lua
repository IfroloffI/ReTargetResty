local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

if not cache then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(cjson.encode({
        error = "Cache not initialized",
        status = "error"
    }))
    return
end

local ok, keys = pcall(function()
    return cache:get_keys(10)
end)

if not ok then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(cjson.encode({
        error = "Failed to get keys: " .. tostring(keys),
        status = "error"
    }))
    return
end

local ok2, capacity, free = pcall(function()
    return cache:capacity(), cache:free_space()
end)

if not ok2 then
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(cjson.encode({
        error = "Failed to get cache stats: " .. tostring(capacity),
        status = "error"
    }))
    return
end

local result = {
    status = "success",
    stats = {
        total_keys = #keys,
        sample_keys = {unpack(keys, 1, math.min(10, #keys))},
        capacity_bytes = capacity,
        used_bytes = capacity - free,
        free_bytes = free,
        used_percent = math.floor((capacity - free) / capacity * 100)
    }
}

ngx.header.content_type = "application/json"
ngx.say(cjson.encode(result))
