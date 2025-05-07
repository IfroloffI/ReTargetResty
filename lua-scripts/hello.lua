local name = ngx.var.arg_name or "Anonymous"
local count = tonumber(ngx.var.arg_count) or 1

ngx.header["X-Lua-Hello"] = "true"
ngx.say("Hello, ", name, "!")
ngx.say("This is request #", count)

if ngx.var.arg_debug == "1" then
    ngx.say("\nDebug info:")
    ngx.say("HTTP Host: ", ngx.var.http_host)
    ngx.say("Remote IP: ", ngx.var.remote_addr)
end
