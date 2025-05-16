local cjson = require "cjson"

if not ngx.ctx.should_cache or ngx.arg[2] ~= "" then
    return
end

local cache = ngx.shared.avatar_cache
local cache_key = ngx.ctx.cache_key
local resp_data = ngx.arg[1]

local content_type = ngx.header["Content-Type"] or ""
if not content_type:match("^image/") then
    ngx.log(ngx.WARN, "Not caching non-image content: ", content_type)
    return
end

local to_cache = {
    data = resp_data,
    content_type = content_type,
    etag = ngx.header["ETag"] or ngx.md5(resp_data),
    timestamp = ngx.time()
}

local success, err = cache:set(cache_key, cjson.encode(to_cache), 300)
if not success then
    ngx.log(ngx.ERR, "Failed to cache avatar: ", err)
else
    ngx.log(ngx.NOTICE, "Successfully cached avatar for key: ", cache_key, " Content-Type: ", content_type)
end
