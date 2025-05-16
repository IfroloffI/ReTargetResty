local cjson = require "cjson"
local sha1 = require "resty.sha1"
local str = require "resty.string"

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local cache_key = "avatar_" .. ngx.md5(session_id)

local cache = ngx.shared.avatar_cache
local method = ngx.var.request_method

if method == "GET" and ngx.var.uri:find("/download") then
    local avatar_data = cache:get(cache_key)

    if avatar_data then
        local cached = cjson.decode(avatar_data)

        local etag = ngx.var.http_if_none_match
        if etag and etag == cached.etag then
            ngx.exit(304)
        end

        ngx.header["Content-Type"] = cached.content_type
        ngx.header["ETag"] = cached.etag
        ngx.header["Cache-Control"] = "public, max-age=300"
        ngx.print(cached.data)
        ngx.exit(200)
    end

    ngx.ctx.cache_key = cache_key
    return
end

if method == "PUT" and ngx.var.uri:find("/upload") then
    cache:delete(cache_key)
    ngx.log(ngx.NOTICE, "Purged avatar cache for: ", cache_key)
    return
end
