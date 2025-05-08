local resty_sha256 = require "resty.sha256"
local str = require "resty.string"
local cache = ngx.shared.my_cache
local random = math.random
local time = ngx.time

-- Конфигурация
local SECRET_KEY = "Kp3s6v9y$B?E(H+Mbt7w!z%C*FQeThWmZq4t7w!z%C*Fp3s6v9y$B?p3s6v9y$B?z%C*FQeThWmZq4t7"
local TOKEN_TTL = 600 -- 10 минут

local function generate_secure_path(link_id)
    local timestamp = math.floor(time() / 300) -- 5 минут
    local sha256 = resty_sha256:new()
    sha256:update(link_id .. SECRET_KEY .. timestamp)
    local digest = sha256:final()
    return "rc_" .. str.to_hex(digest):sub(1, 16)
end

local function validate_link_id(link_id)
    return link_id and #link_id >= 12 and #link_id <= 64 and not link_id:match("[^%w%-_]")
end

-- Main handler
local function handle_request()
    local args = ngx.req.get_uri_args()
    local link_id = args.id or args.link or args.ref

    if not validate_link_id(link_id) then
        ngx.log(ngx.ERR, "Invalid link ID")
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local secure_path = "/resource/" .. generate_secure_path(link_id)
    cache:set("adv:" .. secure_path, link_id, TOKEN_TTL)

    ngx.header["Content-Type"] = "text/html"
    ngx.header["Cache-Control"] = "no-store"
    ngx.print(([[
<!DOCTYPE html>
<html><head>
<meta http-equiv="refresh" content="0;url=%s">
<script>
window.location.replace("%s");
</script>
</head></html>
    ]]):format(secure_path, secure_path))
end

handle_request()
