FROM openresty/openresty:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    gcc \
    make \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/local/openresty/luajit/bin/luarocks install lua-cjson && \
    /usr/local/openresty/luajit/bin/luarocks install lua-resty-sha1

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY lua-scripts/ /usr/local/openresty/lua-scripts/

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]