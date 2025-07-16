#!/bin/bash

# Docker Compose Compatibility Test Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

print_color $BLUE "🐳 Docker Compose Compatibility Test"
print_color $BLUE "===================================="
echo ""

# Test Docker installation
print_color $YELLOW "Testing Docker installation..."
if docker --version > /dev/null 2>&1; then
    print_color $GREEN "✓ Docker is installed: $(docker --version)"
else
    print_color $RED "✗ Docker is not installed"
    exit 1
fi

# Test Docker daemon
print_color $YELLOW "Testing Docker daemon..."
if docker info > /dev/null 2>&1; then
    print_color $GREEN "✓ Docker daemon is running"
else
    print_color $RED "✗ Docker daemon is not running"
    exit 1
fi

# Test Docker Compose v1 (docker-compose)
print_color $YELLOW "Testing Docker Compose v1 (docker-compose)..."
if command -v docker-compose > /dev/null 2>&1; then
    if docker-compose --version > /dev/null 2>&1; then
        print_color $GREEN "✓ Docker Compose v1 is available: $(docker-compose --version)"
        COMPOSE_V1=true
    else
        print_color $RED "✗ Docker Compose v1 command found but not working"
        COMPOSE_V1=false
    fi
else
    print_color $YELLOW "- Docker Compose v1 (docker-compose) not found"
    COMPOSE_V1=false
fi

# Test Docker Compose v2 (docker compose)
print_color $YELLOW "Testing Docker Compose v2 (docker compose)..."
if docker compose version > /dev/null 2>&1; then
    print_color $GREEN "✓ Docker Compose v2 is available: $(docker compose version)"
    COMPOSE_V2=true
else
    print_color $YELLOW "- Docker Compose v2 (docker compose) not found"
    COMPOSE_V2=false
fi

# Test architecture detection
print_color $YELLOW "Testing architecture detection..."
ARCH=$(uname -m)
OS=$(uname -s)
print_color $GREEN "✓ Architecture: $ARCH"
print_color $GREEN "✓ Operating System: $OS"

# Test macOS detection
if [[ "$OS" == "Darwin" ]]; then
    print_color $GREEN "✓ macOS detected"
    if [[ "$ARCH" == "arm64" ]]; then
        print_color $GREEN "✓ Apple Silicon (ARM64) detected"
    else
        print_color $GREEN "✓ Intel Mac (x86_64) detected"
    fi
fi

# Summary
echo ""
print_color $BLUE "Summary:"
print_color $BLUE "========"

if [[ "$COMPOSE_V1" == true ]] && [[ "$COMPOSE_V2" == true ]]; then
    print_color $GREEN "✓ Both Docker Compose v1 and v2 are available"
    print_color $GREEN "  The scripts will automatically use the best available version"
elif [[ "$COMPOSE_V2" == true ]]; then
    print_color $GREEN "✓ Docker Compose v2 is available (recommended)"
    print_color $GREEN "  The scripts will use: docker compose"
elif [[ "$COMPOSE_V1" == true ]]; then
    print_color $YELLOW "✓ Docker Compose v1 is available (legacy)"
    print_color $YELLOW "  The scripts will use: docker-compose"
    print_color $YELLOW "  Consider upgrading to Docker Compose v2"
else
    print_color $RED "✗ No Docker Compose version found"
    print_color $RED "  Please install Docker Desktop or Docker Compose"
    exit 1
fi

# Test the detection function
print_color $YELLOW "Testing compose command detection..."
if command -v docker-compose &> /dev/null; then
    DETECTED_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DETECTED_CMD="docker compose"
else
    print_color $RED "✗ No compose command detected"
    exit 1
fi

print_color $GREEN "✓ Detected compose command: $DETECTED_CMD"

# Test basic compose functionality
print_color $YELLOW "Testing basic compose functionality..."
if $DETECTED_CMD --version > /dev/null 2>&1 || $DETECTED_CMD version > /dev/null 2>&1; then
    print_color $GREEN "✓ Compose command is working"
else
    print_color $RED "✗ Compose command is not working properly"
    exit 1
fi

echo ""
print_color $GREEN "🎉 All tests passed! Your Docker setup is ready for ComfyUI."
print_color $GREEN "   You can now run: ./docker-manage.sh build && ./docker-manage.sh start"
echo ""

# Show recommended next steps
print_color $BLUE "Recommended next steps:"
print_color $BLUE "======================="
if [[ "$OS" == "Darwin" ]]; then
    print_color $YELLOW "For macOS:"
    print_color $YELLOW "  ./launch-macos.sh          # Quick setup"
    print_color $YELLOW "  ./docker-manage.sh build   # Build for your architecture"
    print_color $YELLOW "  ./docker-manage.sh start   # Start ComfyUI"
else
    print_color $YELLOW "For Linux:"
    print_color $YELLOW "  ./docker-manage.sh build   # Build ComfyUI"
    print_color $YELLOW "  ./docker-manage.sh start   # Start ComfyUI"
fi
echo ""
