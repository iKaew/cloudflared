# Cloudflared container image

To build container image for cloudflared release from [cloudflared project](https://github.com/cloudflare/cloudflared)

## Build arguments
- CLOUDFLARED_VERSION - if left unspecified, it will use the latest release
- CLOUDFLARED_OS - linux, ~~windows~~, ~~darwin~~
- CLOUDFLARED_ARCH - 386, amd64, arm, arm64

## How to build
```
docker build .
```