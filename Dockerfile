# Base image from quay.io to avoid Docker Hub limits
# Pick a Go version that matches your toolchain needs
FROM quay.io/projectquay/golang:1.22 AS base

WORKDIR /app

# Copy source (adjust paths to your project)
COPY . .

# Optional: run unit tests during build (will fail the build on test failure)
# Comment out if you don't have tests yet.
# RUN go test ./...

# Build a small static binary (CGO disabled for portability)
ARG APP=demo
ARG VERSION=0.1.0
ENV CGO_ENABLED=0
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /usr/local/bin/${APP} main.go

# Minimal runtime from the same base (single stage for clarity with plain docker build)
# If you prefer, you can keep the binary in this same image without a second FROM,
# but here we simply reuse the current stage as runtime.
ENTRYPOINT ["/usr/local/bin/demo"]
