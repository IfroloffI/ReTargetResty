local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.status = 401
    ngx.say('{"error": "Unauthorized"}')
    return ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)
ngx.ctx.cache_key = cache_key

if ngx.var.request_method == "GET" then
    local cached = cache:get(cache_key)
    if cached then
        local ok, data = pcall(zlib.inflate, zlib, cached)
        if ok then
            ngx.header["Content-Type"] = "image/jpeg"
            ngx.print(data)
            return ngx.exit(200)
        else
            ngx.log(ngx.ERR, "Decompression failed: ", data)
            cache:delete(cache_key)
        end
    end
end

if ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
    ngx.exit(200)
end
