local cjson = require "cjson"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)

if ngx.var.request_method == "GET" then
    local cached = cache:get(cache_key)
    if cached then
        ngx.print(cached)
        return ngx.exit(200)
    end
end

if ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
    ngx.exit(200)
end
