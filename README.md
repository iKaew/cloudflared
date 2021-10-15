# Cloudflared container image

To build multi-arch container image for cloudflared release from [cloudflared project](https://github.com/cloudflare/cloudflared)

## Usage
Start cloudflared help

- `docker run --rm -it hellopeera/cloudflared --help`

Start Argo Tunnel hello world

- `docker run --rm -it hellopeera/cloudflared tunnel --hello-world`

## Dockerfile
### Build arguments
- CLOUDFLARED_VERSION - if left unspecified, it will use the latest release

### How to build
Build image using latest cloudflare release
- `docker build .`

Build image using specific cloudflare release
- `docker build --build-arg CLOUDFLARED_VERSION=2021.9.2 .`
