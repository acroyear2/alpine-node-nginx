#!/bin/bash

function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

REWRITES_PART=

REWRITE_PATHS=(${REWRITE_PATHS// / })

if [ ${#REWRITE_PATHS[@]} -gt 0 ]; then
    REWRITE_PATHS=$(join_by '|' "${REWRITE_PATHS[@]}")

    read -r -d '' REWRITES_PART << EOM
        location ~ /($REWRITE_PATHS)/ {
            try_files \$uri \$uri/ /index.html;
        }

        location ~ /($REWRITE_PATHS)/?\$ {
            try_files \$uri \$uri/ /index.html;
        }
EOM
fi

EXTERNAL_ENDPOINT=${NODE_EXTERNAL_ENDPOINT:-"api/"}
INTERNAL_ENDPOINT=${NODE_INTERNAL_ENDPOINT:-"api/"}

API_PART=

[ ! -z "$HAS_NODE" ] && {
    read -r -d '' API_PART << EOM
        location /$EXTERNAL_ENDPOINT {
            proxy_pass                http://node/$INTERNAL_ENDPOINT;
            proxy_http_version        1.1;
            proxy_set_header          X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header          Host \$host;
            proxy_buffering           off;
            proxy_request_buffering   off;
        }
EOM
}

cat > /etc/nginx/nginx.conf <<EOF
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    server_tokens      off;
    root               /usr/share/nginx/html;
    include            mime.types;
    default_type       application/octet-stream;
    gzip               on;
    gzip_comp_level    5;
    gzip_min_length    192;
    gzip_proxied       any;
    gzip_vary          on;
    gzip_types
      application/atom+xml
      application/javascript
      application/json
      application/rss+xml
      application/vnd.ms-fontobject
      application/x-font-ttf
      application/x-web-app-manifest+json
      application/xhtml+xml
      application/xml
      application/octet-stream
      font/opentype
      image/svg+xml
      image/x-icon
      text/css
      text/plain
      text/x-component;

    upstream node {
        server   127.0.0.1:9000;
    }

    server {
        listen               80 default_server;
        server_name          _;
        sendfile             on;
        keepalive_timeout    65;

        $API_PART

        $REWRITES_PART

        location / {
            index  index.html;
        }
    }
}
EOF

nginx -g 'pid /tmp/nginx.pid; daemon off;'
