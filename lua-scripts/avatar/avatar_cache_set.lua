local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

ngx.log(ngx.NOTICE, "Body filter started. Cache key: ", ngx.ctx.cache_key or "nil")

if ngx.ctx.cache_key and ngx.status == 200 and ngx.arg[2] == "" then
    ngx.log(ngx.NOTICE, "Caching conditions met")

    local data = ngx.arg[1]
    if not data or #data == 0 then
        ngx.log(ngx.WARN, "Empty data, skipping cache")
        return
    end

    local ok, compressed = pcall(zlib.deflate, zlib, data)
    if not ok then
        ngx.log(ngx.ERR, "Compression failed: ", compressed)
        return
    end

    local success, err = cache:set(ngx.ctx.cache_key, compressed, 300)
    if success then
        ngx.log(ngx.NOTICE, "Successfully cached ", #compressed, " bytes")
        ngx.header["X-Cache-Status"] = "CACHED"
    else
        ngx.log(ngx.ERR, "Cache set failed: ", err)
    end
else
    ngx.log(ngx.NOTICE, "Caching conditions NOT met: ", "key=", ngx.ctx.cache_key and "exists" or "nil", " status=",
        ngx.status, " body_chunk=", ngx.arg[2] and "exists" or "nil")
end
