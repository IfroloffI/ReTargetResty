local zlib = require "zlib"
local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.status = 401
    ngx.header["Content-Type"] = "application/json"
    ngx.say('{"error": "Unauthorized"}')
    return ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)
ngx.ctx.cache_key = cache_key

if ngx.var.request_method == "GET" then
    local cached = cache:get(cache_key)
    if cached then
        local ok, data = pcall(cjson.decode, cached)
        if ok then
            local ok_decompress, img_data = pcall(zlib.inflate, zlib, data.data)
            if ok_decompress then
                ngx.header["Content-Type"] = data.content_type
                ngx.print(img_data)
                return ngx.exit(200)
            else
                cache:delete(cache_key)
                ngx.log(ngx.ERR, "Decompression failed: ", img_data)
            end
        else
            cache:delete(cache_key)
            ngx.log(ngx.ERR, "Cache data corruption: ", data)
        end
    end
end

if ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
    ngx.log(ngx.NOTICE, "Cache purged for: ", cache_key)
    ngx.exit(200)
end
