local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

if not cache then
    ngx.log(ngx.ERR, "Cache initialization failed")
    return ngx.exit(500)
end

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.log(ngx.WARN, "Missing session_id cookie")
    return ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)
local method = ngx.var.request_method

ngx.log(ngx.NOTICE, "Request method: ", method, " Cache key: ", cache_key)

if method == "GET" then
    local cached = cache:get(cache_key)
    if cached then
        ngx.log(ngx.NOTICE, "Cache HIT")
        local ok, data = pcall(zlib.inflate, zlib, cached)
        if ok then
            ngx.header["X-Cache-Status"] = "HIT"
            ngx.print(data)
            return ngx.exit(200)
        else
            ngx.log(ngx.ERR, "Decompression failed: ", data)
        end
    end

    ngx.log(ngx.NOTICE, "Cache MISS")
    ngx.ctx.cache_key = cache_key
    ngx.header["X-Cache-Status"] = "MISS"
    return
end

if method == "PUT" then
    cache:delete(cache_key)
    ngx.log(ngx.NOTICE, "Cache PURGED")
    ngx.header["X-Cache-Status"] = "PURGED"
    return
end

ngx.log(ngx.WARN, "Invalid method: ", method)
return ngx.exit(405)
