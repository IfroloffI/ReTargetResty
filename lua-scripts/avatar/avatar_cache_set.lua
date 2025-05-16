local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

if ngx.ctx.cache_key and ngx.status == 200 and ngx.arg[2] == "" then
    local compressed = zlib.deflate()(ngx.arg[1])
    cache:set(ngx.ctx.cache_key, compressed, 300)
    ngx.header["X-Cache-Status"] = "CACHED"
end
