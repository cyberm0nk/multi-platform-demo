# Multi-Platform Demo

This repository demonstrates how to build and test Go applications across multiple operating systems and architectures, and how to containerize the app using Docker with an alternative container registry.

## ✨ Features
- **Cross-platform builds** via `Makefile` (Linux, macOS, Windows, amd64, arm64)
- **Simple Go demo app** (`main.go`)
- **Dockerfile** based on `quay.io/projectquay/golang` (avoiding Docker Hub limits)
- **Make targets** for building binaries, creating Docker images, and cleaning up

## 🚀 Quick Start

### 1. Clone the repo
```bash
git clone git@github.com:cyberm0nk/multi-platform-demo.git
cd multi-platform-demo
```

### 2. Build the app for your host
```bash
make build
```

### 3. Cross-compile for other platforms
```bash
make linux
make darwin
make windows
make arm64
make amd64
```

### 4. Build the Docker image (host platform only)
```bash
make image
```

### 5. Run the container
```bash
docker run --rm quay.io/cyberm0nk/demo:0.1.0
```

### 6. Clean up Docker image
```bash
make clean
```

### 📂 Repository Structure
```bash
.
├── main.go        # Simple Go demo application
├── Makefile       # Build instructions for cross-platform targets + Docker
└── Dockerfile     # Container image definition (quay.io base)
```
