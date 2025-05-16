FROM openresty/openresty:bookworm

RUN apt-get update && \
    apt-get install -y luarocks && \
    rm -rf /var/lib/apt/lists/*

RUN luarocks install lua-cjson
RUN luarocks install lua-zlib

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf