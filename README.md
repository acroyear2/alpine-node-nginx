# alpine-node-nginx

a Docker image based on [mhart/alpine-node:4](https://github.com/mhart/alpine-node) with nginx added.

```
docker run -it --rm -p 8080:80 \
	-e HAS_NODE=1 \
	-e REWRITE_PATHS='bar baz' \
	tetsuo/alpine-node-nginx
```

This generates an `/etc/nginx/nginx.conf` file with a single worker process setting before it starts an nginx instance.

## Pre-configured `proxy_pass`

By default, the newly generated `nginx.conf` file does not contain any [`proxy_pass`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass) directives and is only configured to serve files in the `/usr/share/nginx/html` directory. However, it is possible to add those configurations using the following environment variables:

- `HAS_NODE` has to be set if proxying to nodejs is desired
- `NODE_EXTERNAL_ENDPOINT` is the external endpoint that points to the nodejs app (default: `api/`)
- `NODE_INTERNAL_ENDPOINT` is the internal app endpoint where the requests will be forwarded to (default: `api/`)

## Rewrites for client-side routing

When set, `REWRITE_PATHS` environment variable should contain a single-space separated list of paths which will serve `index.html` as well. This is especially useful for applications that has client-side based routing using `pushState()` or whatever.

## Basic authentication

You can set `HAS_BASIC_AUTH` value to add HTTP authentication for free. By default, username and password is `admin:admin`. You can change these to different values using `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD` environment variables.

