local zlib = require "zlib"
local cache = ngx.shared.avatar_cache

local session_id = ngx.var.cookie_session_id
if not session_id then
    return ngx.exit(401)
end

local cache_key = "avatar_" .. ngx.md5(session_id)

if ngx.var.request_method == "GET" then
    local cached = cache:get(cache_key)
    if cached then
        ngx.print(zlib.inflate()(cached))
        return ngx.exit(200)
    end
end

if ngx.var.request_method == "PUT" then
    cache:delete(cache_key)
    return
end

ngx.req.read_body()
local res = ngx.location.capture("/proxy_pass")

if ngx.var.request_method == "GET" and res.status == 200 then
    cache:set(cache_key, zlib.deflate()(res.body), 300)
end

ngx.status = res.status
ngx.print(res.body)
