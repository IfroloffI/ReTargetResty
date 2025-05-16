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
        cache:set(cache_key, cached, 300)
        ngx.header["Content-Type"] = "image/jpeg"
        ngx.print(cached)
        ngx.exit(200)
    else
        local res = ngx.location.capture("/internal-avatar", {
            method = ngx.HTTP_GET,
            args = ngx.req.get_uri_args()
        })
        if res.status ~= 200 then
            ngx.exit(res.status)
        end
        cache:set(cache_key, res.body, 300)
        ngx.print(res.body)
        ngx.exit(200)
    end
elseif ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
    ngx.exit(200)
else
    ngx.exit(405)
end
