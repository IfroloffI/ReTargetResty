FROM openresty/openresty:bookworm

RUN apt-get update && \
    apt-get install -y zlib1g-dev && \
    apt-get install -y luarocks && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN luarocks install lua-cjson
RUN luarocks install lua-zlib

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf