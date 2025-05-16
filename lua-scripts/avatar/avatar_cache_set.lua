local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

if not cache then
    ngx.log(ngx.ERR, "Avatar cache not initialized in body filter")
    return
end

if ngx.arg[2] ~= "" then
    return
end

if not ngx.ctx.cache_avatar or ngx.status ~= 200 then
    return
end

local cache_key = ngx.ctx.cache_key
if not cache_key then
    ngx.log(ngx.ERR, "No cache_key in ctx in body filter")
    return
end

local content_type = ngx.header["Content-Type"] or ""
if not content_type:match("^image/") then
    ngx.log(ngx.WARN, "Not caching non-image content: ", content_type)
    return
end

local data = ngx.arg[1]
local etag = ngx.header["ETag"] or ngx.md5(data)

local to_cache = {
    data = data,
    content_type = content_type,
    etag = etag,
    timestamp = ngx.time()
}

local ok, err = cache:set(cache_key, cjson.encode(to_cache), 300) -- TTL 5 минут
if not ok then
    ngx.log(ngx.ERR, "Failed to cache avatar: ", err)
else
    ngx.log(ngx.NOTICE, "Successfully cached avatar for key: ", cache_key, " (", #data, " bytes)")
    ngx.header["X-Cache-Status"] = "STORE"
end
