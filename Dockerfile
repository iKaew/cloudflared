FROM golang:alpine as builder

ARG CLOUDFLARED_VERSION
ARG CLOUDFLARED_REPO=cloudflare/cloudflared
ARG CLOUDFLARED_SOURCE=https://github.com/${CLOUDFLARED_REPO}/archive/refs/tags
ARG CLOUDFLARED_LATEST_INFO=https://api.github.com/repos/${CLOUDFLARED_REPO}/releases/latest

WORKDIR /go/src/github.com/cloudflare/cloudflared

# Make static binary
ENV CGO_ENABLED 0

RUN \
  set -xeo pipefail \
  && apk add --no-cache build-base curl tar

RUN \
  set -xeo pipefail \
  # if CLOUDFLARED_VERSION is not specified, then find the latest version
  && { \
    if [[ -z "${CLOUDFLARED_VERSION}" ]]; then \
      CLOUDFLARED_VERSION=$(curl -s ${CLOUDFLARED_LATEST_INFO} | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); \
    fi; \
  } \ 
  && curl -L "${CLOUDFLARED_SOURCE}/${CLOUDFLARED_VERSION}.tar.gz" -o /tmp/cloudflared.tar.gz \
  && tar xzf /tmp/cloudflared.tar.gz --strip 1 \
  && make cloudflared

# ----------------------------------------------------------------

FROM alpine:latest

ARG BUILD_DATE
ARG CLOUDFLARED_VERSION

LABEL org.opencontainers.image.authors "hellopeera <https://github.com/hellopeera>"
LABEL org.opencontainers.image.url "https://github.com/hellopeera/cloudflared"
LABEL org.opencontainers.image.documentation "https://github.com/hellopeera/cloudflared"
LABEL org.opencontainers.image.source "https://github.com/hellopeera/cloudflared"
LABEL org.opencontainers.image.title "hellopeera/cloudflared"
LABEL org.opencontainers.image.description "Cloudflare's command-line client for Cloudflare Tunnel"
LABEL org.opencontainers.image.created "${BUILD_DATE}"
LABEL org.opencontainers.image.version "${CLOUDFLARED_VERSION}"

COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

RUN \
  set -xeo pipefail \
  && apk update \
  && apk upgrade \
  && apk add ca-certificates bind-tools curl libcap tzdata \
  && setcap 'cap_net_bind_service=+ep' /usr/local/bin/cloudflared

USER nobody

ENV TUNNEL_DNS_ADDRESS "0.0.0.0"
ENV TUNNEL_DNS_PORT "53"
ENV TUNNEL_DNS_UPSTREAM "https://1.1.1.1/dns-query,https://1.0.0.1/dns-query"
ENV TUNNEL_METRICS "0.0.0.0:10080"

ENTRYPOINT ["cloudflared", "--no-autoupdate"]

RUN ["cloudflared", "--version"]
