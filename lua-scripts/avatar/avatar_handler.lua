local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.exit(401)
end

if ngx.var.request_method == "GET" then
    local cache_key = "avatar_" .. ngx.md5(session_id)
    local cached = cache:get(cache_key)
    if cached then
        cache:set(cache_key, cached, 300)
        ngx.header["Content-Type"] = "image/jpeg"
        ngx.print(cached)
        ngx.exit(200)
    end
end
if ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
end
