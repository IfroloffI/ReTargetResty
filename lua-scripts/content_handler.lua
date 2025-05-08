local resty_sha256 = require "resty.sha256"
local str = require "resty.string"
local cache = ngx.shared.my_cache
local time = ngx.time

-- Конфигурация
local SECRET_KEY = "Kp3s6v9y$B?E(H+Mbt7w!z%C*FQeThWmZq4t7w!z%C*Fp3s6v9y$B?p3s6v9y$B?z%C*FQeThWmZq4t7"
local TOKEN_TTL = 600 -- 10 минут

local function generate_token(link_id)
    local timestamp = math.floor(time() / 300) -- 5 минут
    local sha256 = resty_sha256:new()
    sha256:update(link_id .. SECRET_KEY .. timestamp)
    return "rc_" .. str.to_hex(sha256:final()):sub(1, 16)
end

local function validate_link(link_id)
    return link_id and #link_id >= 8 and #link_id <= 64 and not link_id:match("[^%w%-_]")
end

local function handle()
    local args = ngx.req.get_uri_args()
    local link_id = args.id or args.link or args.ref

    if not validate_link(link_id) then
        ngx.log(ngx.ERR, "Invalid link ID: ", link_id or "nil")
        return ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local token = generate_token(link_id)
    local target_path = "/resource/" .. token

    -- Сохраняем в кеш
    local ok, err = cache:set("adv:" .. token, link_id, TOKEN_TTL)
    if not ok then
        ngx.log(ngx.ERR, "Cache set failed: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- Отдаём редирект
    ngx.header["Content-Type"] = "text/html"
    ngx.header["Cache-Control"] = "no-store"
    ngx.print(([[
<!doctype html>
<html>
<head>
<meta http-equiv="refresh" content="0;url=%s">
<script>window.location.href="%s";</script>
</head>
<body></body>
</html>
    ]]):format(target_path, target_path))
end

handle()
