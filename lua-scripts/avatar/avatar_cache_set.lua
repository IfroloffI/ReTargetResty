local cjson = require "cjson"

if not ngx.ctx.cache_avatar or ngx.arg[2] ~= "" then
    return
end

local cache = ngx.shared.avatar_cache
local cache_key = ngx.ctx.cache_key
local resp_data = ngx.arg[1]

local compressed_data = resp_data -- TODO: Сжатие сделать

local to_cache = {
    data = compressed_data,
    content_type = ngx.header["Content-Type"],
    etag = ngx.header["ETag"] or ngx.md5(resp_data),
    timestamp = ngx.time()
}

cache:set(cache_key, cjson.encode(to_cache), 300)

ngx.log(ngx.NOTICE, "Cached avatar for: ", cache_key)
