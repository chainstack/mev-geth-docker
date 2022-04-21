# Build Geth in a stock Go builder container
FROM golang:1.18-alpine as builder

ENV MEV_GETH_VERSION="1.10.17-mev0.6.1"

WORKDIR /build

RUN apk add --no-cache gcc musl-dev linux-headers git && \
    git clone --branch v$MEV_GETH_VERSION https://github.com/flashbots/mev-geth.git --depth 1 && \
    cd mev-geth && go run build/ci.go install ./cmd/geth

# Pull MEV-Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /build/mev-geth/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]
