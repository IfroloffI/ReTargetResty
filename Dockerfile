FROM openresty/openresty:bookworm

RUN /usr/local/openresty/luajit/bin/luarocks install lua-cjson

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua-scripts/ /usr/local/openresty/lua-scripts/

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]