local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

if not cache then
    ngx.log(ngx.ERR, "Failed to get shared dictionary 'avatar_cache'")
    return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.log(ngx.WARN, "No session_id in cookies")
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local cache_key = "avatar_" .. ngx.md5(session_id)
local method = ngx.var.request_method

-- Обработка GET запроса
if method == "GET" then
    local args = ngx.req.get_uri_args()

    local cached = cache:get(cache_key)
    if cached then
        cached = cjson.decode(cached)
        local etag = ngx.var.http_if_none_match
        if etag and etag == cached.etag then
            ngx.header["X-Cache-Status"] = "HIT"
            return ngx.exit(304)
        end

        ngx.header["Content-Type"] = cached.content_type
        ngx.header["ETag"] = cached.etag
        ngx.header["Content-Disposition"] = "attachment; filename=avatar"
        ngx.header["Cache-Control"] = "public, max-age=300"
        ngx.header["X-Cache-Status"] = "GFC"
        ngx.print(cached.data)
        return ngx.exit(200)
    end

    ngx.ctx.cache_key = cache_key
    ngx.ctx.should_cache = true
    return
end

-- Обработка PUT запроса
if method == "PUT" then
    cache:delete(cache_key)
    ngx.header["X-Cache-Status"] = "DFC"
    ngx.log(ngx.NOTICE, "Purged avatar cache for: ", cache_key)
    return
end
