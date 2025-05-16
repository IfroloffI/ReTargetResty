local cache = ngx.shared.avatar_cache

if not cache then
    ngx.log(ngx.ERR, "Avatar cache not initialized in body filter")
    return
end

if ngx.arg[2] ~= "" then
    return
end

if not ngx.ctx.should_cache or ngx.status ~= 200 then
    return
end

local cache_key = ngx.ctx.cache_key
if not cache_key then
    ngx.log(ngx.ERR, "No cache_key in ctx in body filter")
    return
end

local content_type = ngx.header["Content-Type"] or ""
if not content_type:match("^image/(jpeg|png|gif)") then
    ngx.log(ngx.WARN, "Not caching non-image content: ", content_type)
    return
end

local data = ngx.arg[1]
if not data or #data == 0 then
    ngx.log(ngx.WARN, "Empty response body, not caching")
    return
end

if #data > 10 * 1024 * 1024 then
    ngx.log(ngx.WARN, "Image too large for caching: ", #data, " bytes")
    return
end

local ok_data, err_data = cache:set(cache_key, data, 300)
local ok_type, err_type = cache:set(cache_key .. "_content_type", content_type, 300)

if not ok_data or not ok_type then
    ngx.log(ngx.ERR, "Failed to cache avatar: ", err_data or err_type)
else
    ngx.log(ngx.NOTICE, "Successfully cached avatar for key: ", cache_key, " (", #data, " bytes, ", content_type, ")")
    ngx.header["X-Cache-Status"] = "CACHED"
end
