FROM openresty/openresty:bookworm

RUN apt-get update && \
    apt-get install -y luarocks && \
    luarocks install lua-cjson && \
    luarocks install lua-resty-sha1

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua-scripts/ /usr/local/openresty/lua-scripts/

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]