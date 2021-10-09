FROM alpine:latest

ARG CLOUDFLARED_VERSION=
ARG CLOUDFLARED_OS=linux
ARG CLOUDFLARED_ARCH=
ARG CLOUDFLARED_REPO=cloudflare/cloudflared
ARG CLOUDFLARED_BIN=https://github.com/${CLOUDFLARED_REPO}/releases/download

RUN \
  set -x && \
  apk update && \
  apk upgrade && \
  apk add tzdata ca-certificates libcap bind-tools curl libc6-compat

RUN \
  set -x && \
  [[ -z "${CLOUDFLARED_ARCH}" ]] && CLOUDFLARED_ARCH="$(uname -m)" || true && \
  [[ "${CLOUDFLARED_ARCH}" == "x86_64" ]] && CLOUDFLARED_ARCH="amd64" || true && \
  [[ "${CLOUDFLARED_ARCH}" == "aarch64" ]] && CLOUDFLARED_ARCH="arm64" || true && \
  [[ "${CLOUDFLARED_ARCH}" == "armv7l" ]] && CLOUDFLARED_ARCH="arm" || true && \
  [[ -z "${CLOUDFLARED_VERSION}" ]] && \
    CLOUDFLARED_VERSION=$(curl -s https://api.github.com/repos/${CLOUDFLARED_REPO}/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') || true && \
  curl -L --fail -o /usr/local/bin/cloudflared ${CLOUDFLARED_BIN}/${CLOUDFLARED_VERSION}/cloudflared-${CLOUDFLARED_OS}-${CLOUDFLARED_ARCH} && \
  chmod ugo+x /usr/local/bin/cloudflared && \
  setcap 'cap_net_bind_service=+ep' /usr/local/bin/cloudflared

USER nobody

ENV TUNNEL_DNS_ADDRESS "0.0.0.0"
ENV TUNNEL_DNS_PORT "53"
ENV TUNNEL_DNS_UPSTREAM "https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
ENV TUNNEL_METRICS "0.0.0.0:10080"

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

RUN ["cloudflared", "--version"]
