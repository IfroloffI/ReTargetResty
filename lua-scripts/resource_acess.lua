local cache = ngx.shared.my_cache
local path = ngx.var.uri
local link_id = cache:get("res:" .. path)

if not link_id then
    ngx.log(ngx.ERR, "Invalid or expired token: ", path)
    return ngx.exit(ngx.HTTP_GONE)
end

ngx.var.target_link = link_id
cache:delete("res:" .. path)
