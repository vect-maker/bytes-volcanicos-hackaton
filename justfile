set dotenv-load

# Mount sub-repositories as native modules
mod backend
mod frontend

# List available recipes
default:
    @just --list

# Install dependencies and bootstrap both frontend and backend
setup:
    @echo "==> Bootstrapping backend keys..."
    just backend::bootstrap-keys
    @echo "==> Downloading ML model (CLIP)..."
    just backend::download-model
    @echo "==> Installing frontend dependencies..."
    just frontend::install

# Build both backend and frontend
build:
    @echo "==> Building backend (debug images)..."
    just backend::build-all-debug
    @echo "==> Building frontend image..."
    just frontend::build-image

# Run type checks and validations across the stack
check:
    @echo "==> Checking frontend..."
    just frontend::typecheck

# Open development environment in Zellij
dev:
    zellij --layout .zellij.kdl

# Launch ChartDB database visualizer via Podman (http://localhost:8085)
chartdb port="8085":
    @echo "==> Launching ChartDB at http://localhost:{{port}}..."
    podman run --rm -it -p {{port}}:80 --name chartdb ghcr.io/chartdb/chartdb:latest

