local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    return ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)
local method = ngx.var.request_method

-- GET: Возврат из кеша
if method == "GET" then
    local compressed = cache:get(cache_key)
    if compressed then
        ngx.print(zlib.inflate()(compressed))
        ngx.header["X-Cache-Status"] = "HIT"
        return ngx.exit(200)
    end
    ngx.ctx.cache_key = cache_key
    ngx.header["X-Cache-Status"] = "MISS"
    return
end

-- PUT: Очистка кеша
if method == "PUT" then
    cache:delete(cache_key)
    ngx.header["X-Cache-Status"] = "PURGED"
    return
end

-- Блок
ngx.header["X-Cache-Status"] = "DENIED"
return ngx.exit(405)
