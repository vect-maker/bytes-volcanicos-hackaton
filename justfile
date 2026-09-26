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
    @echo "==> Installing frontend dependencies..."
    just frontend::install

# Build both backend and frontend
build:
    @echo "==> Building backend (debug images)..."
    just backend::build-all-debug
    @echo "==> Building frontend..."
    just frontend::build

# Run type checks and validations across the stack
check:
    @echo "==> Checking frontend..."
    just frontend::typecheck

# Open development environment in Zellij
dev:
    zellij --layout .zellij.kdl
