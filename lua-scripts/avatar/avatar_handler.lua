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
    local cached_data = cache:get(cache_key)
    if cached_data then
        local cached_type = cache:get(cache_key .. "_content_type") or "image/jpeg"

        ngx.header["Content-Type"] = cached_type
        ngx.header["Content-Disposition"] = "attachment; filename=avatar"
        ngx.header["Cache-Control"] = "public, max-age=300"
        ngx.header["X-Cache-Status"] = "HIT"
        ngx.print(cached_data)
        return ngx.exit(200)
    end

    ngx.ctx.cache_key = cache_key
    ngx.ctx.should_cache = true
    ngx.header["X-Cache-Status"] = "MISS"
    return
end

-- Обработка PUT запроса
if method == "PUT" then
    cache:delete(cache_key)
    ngx.header["X-Cache-Status"] = "PURGED"
    ngx.log(ngx.NOTICE, "Purged avatar cache for: ", cache_key)
    return
end
