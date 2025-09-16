# -----------------------------
# Cross-platform build Makefile
# -----------------------------
# This Makefile builds Go binaries for multiple OS/ARCH targets using pure Go
# cross-compilation (no Docker, no buildx). It also provides a Docker image
# build target using standard `docker build` (host platform only).
#
# Targets (examples):
#   make linux        # GOOS=linux,    GOARCH from host (or override)
#   make darwin       # GOOS=darwin,   GOARCH from host (or override)
#   make windows      # GOOS=windows,  GOARCH from host (or override)
#   make arm64        # GOOS from host, GOARCH=arm64
#   make amd64        # GOOS from host, GOARCH=amd64
#   make image        # docker build (host platform)
#   make clean        # remove docker image <IMAGE_TAG>
#
# Notes:
# - To run a non-native binary you need the matching OS/ARCH runtime.
# - Docker image build here is standard `docker build` (host platform only),
#   as required by the task (no buildx).
# - Base image comes from quay.io to avoid Docker Hub limits.

APP          ?= demo
PKG          ?= .
BIN_DIR      ?= bin
MAIN         ?= main.go

# Default version label for the image (can be overridden)
VERSION      ?= 0.1.0
IMAGE_NAME   ?= quay.io/cyberm0nk/$(APP)
IMAGE_TAG    ?= $(IMAGE_NAME):$(VERSION)

# Host GO parameters (can be overridden)
HOST_GOOS    ?= $(shell go env GOOS)
HOST_GOARCH  ?= $(shell go env GOARCH)

# Common go build flags (no cgo to simplify cross-compile)
CGO_ENABLED  ?= 0
LDFLAGS      ?=
GCFLAGS      ?=

# Utility
MKDIR_P      := mkdir -p

.PHONY: all linux darwin windows arm64 amd64 build image clean echo-tag

all: build

# Build for current host
build:
	@$(MKDIR_P) $(BIN_DIR)/$(HOST_GOOS)-$(HOST_GOARCH)
	@echo ">> Building for $(HOST_GOOS)/$(HOST_GOARCH)"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(HOST_GOOS) GOARCH=$(HOST_GOARCH) \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/$(HOST_GOOS)-$(HOST_GOARCH)/$(APP) $(MAIN)
	@echo "OK -> $(BIN_DIR)/$(HOST_GOOS)-$(HOST_GOARCH)/$(APP)"

# OS-specific targets (arch inherits host unless overridden)
linux:
	@$(MKDIR_P) $(BIN_DIR)/linux-$(HOST_GOARCH)
	@echo ">> Building for linux/$(HOST_GOARCH)"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=linux GOARCH=$(HOST_GOARCH) \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/linux-$(HOST_GOARCH)/$(APP) $(MAIN)
	@echo "OK -> $(BIN_DIR)/linux-$(HOST_GOARCH)/$(APP)"

darwin:
	@$(MKDIR_P) $(BIN_DIR)/darwin-$(HOST_GOARCH)
	@echo ">> Building for darwin/$(HOST_GOARCH)"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=darwin GOARCH=$(HOST_GOARCH) \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/darwin-$(HOST_GOARCH)/$(APP) $(MAIN)
	@echo "OK -> $(BIN_DIR)/darwin-$(HOST_GOARCH)/$(APP)"

windows:
	@$(MKDIR_P) $(BIN_DIR)/windows-$(HOST_GOARCH)
	@echo ">> Building for windows/$(HOST_GOARCH)"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=windows GOARCH=$(HOST_GOARCH) \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/windows-$(HOST_GOARCH)/$(APP).exe $(MAIN)
	@echo "OK -> $(BIN_DIR)/windows-$(HOST_GOARCH)/$(APP).exe"

# ARCH-specific targets (OS inherits host unless overridden)
arm64:
	@$(MKDIR_P) $(BIN_DIR)/$(HOST_GOOS)-arm64
	@echo ">> Building for $(HOST_GOOS)/arm64"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(HOST_GOOS) GOARCH=arm64 \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/$(HOST_GOOS)-arm64/$(APP) $(MAIN)
	@echo "OK -> $(BIN_DIR)/$(HOST_GOOS)-arm64/$(APP)"

amd64:
	@$(MKDIR_P) $(BIN_DIR)/$(HOST_GOOS)-amd64
	@echo ">> Building for $(HOST_GOOS)/amd64"
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(HOST_GOOS) GOARCH=amd64 \
		go build -ldflags "$(LDFLAGS)" -gcflags "$(GCFLAGS)" \
		-o $(BIN_DIR)/$(HOST_GOOS)-amd64/$(APP) $(MAIN)
	@echo "OK -> $(BIN_DIR)/$(HOST_GOOS)-amd64/$(APP)"

# Docker image build using standard docker build (host platform only)
image:
	@echo ">> Building docker image: $(IMAGE_TAG) (host platform)"
	docker build --build-arg APP=$(APP) --build-arg VERSION=$(VERSION) -t $(IMAGE_TAG) .

# Print the image tag (useful in shell expansions)
echo-tag:
	@echo $(IMAGE_TAG)

# Clean docker image as required by the task
clean:
	@echo ">> Removing docker image: $(IMAGE_TAG)"
	-docker rmi $(IMAGE_TAG)
