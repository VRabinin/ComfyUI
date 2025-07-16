#!/bin/bash

# ComfyUI macOS Launch Script
# Optimized for Apple Silicon (M1/M2/M3) and Intel Macs

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

# Function to print banner
print_banner() {
    echo ""
    print_color $BLUE "╔══════════════════════════════════════════════════════════════════════════════╗"
    print_color $BLUE "║                              ComfyUI for macOS                              ║"
    print_color $BLUE "║                    Docker Setup for Apple Silicon & Intel                   ║"
    print_color $BLUE "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Function to detect system info
detect_system() {
    local arch=$(uname -m)
    local os=$(uname -s)
    local chip_info=""
    
    if [[ "$os" == "Darwin" ]]; then
        # Try to get chip info on macOS
        if command -v system_profiler &> /dev/null; then
            chip_info=$(system_profiler SPHardwareDataType | grep "Chip:" | awk '{print $2, $3}' | head -1)
        fi
        
        if [[ "$arch" == "arm64" ]]; then
            print_color $GREEN "✓ Detected: macOS Apple Silicon ($chip_info)"
            echo "arm64"
        else
            print_color $YELLOW "✓ Detected: macOS Intel"
            echo "x86_64"
        fi
    else
        print_color $RED "✗ This script is designed for macOS"
        echo "unknown"
    fi
}

# Function to check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_color $RED "✗ Docker not found. Please install Docker Desktop for Mac"
        print_color $YELLOW "  Download from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_color $RED "✗ Docker is not running. Please start Docker Desktop"
        exit 1
    fi
    
    print_color $GREEN "✓ Docker is running"
}

# Function to check Docker Compose
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        print_color $GREEN "✓ Docker Compose (v1) is available"
        echo "docker-compose"
    elif docker compose version &> /dev/null 2>&1; then
        print_color $GREEN "✓ Docker Compose (v2) is available"
        echo "docker compose"
    else
        print_color $RED "✗ Docker Compose not found"
        exit 1
    fi
}

# Function to build ComfyUI
build_comfyui() {
    local arch=$1
    local compose_cmd=$2
    
    print_color $BLUE "Building ComfyUI for $arch architecture..."
    
    if [[ "$arch" == "arm64" ]]; then
        print_color $YELLOW "  Using ARM64 optimized build with MPS support"
        $compose_cmd -f docker-compose.arm64.yaml build
    else
        print_color $YELLOW "  Using native macOS build"
        $compose_cmd -f docker-compose.native.yaml build
    fi
    
    print_color $GREEN "✓ Build completed successfully!"
}

# Function to start ComfyUI
start_comfyui() {
    local arch=$1
    local compose_cmd=$2
    
    print_color $BLUE "Starting ComfyUI..."
    
    if [[ "$arch" == "arm64" ]]; then
        print_color $YELLOW "  Using ARM64 container with MPS acceleration"
        $compose_cmd -f docker-compose.arm64.yaml up -d
    else
        print_color $YELLOW "  Using native macOS container"
        $compose_cmd -f docker-compose.native.yaml up -d
    fi
    
    print_color $GREEN "✓ ComfyUI is starting up..."
    print_color $GREEN "✓ Access ComfyUI at: http://localhost:8188"
    
    # Wait a moment and check if container is running
    sleep 3
    if [[ "$arch" == "arm64" ]]; then
        if $compose_cmd -f docker-compose.arm64.yaml ps -q comfyui-m2 &> /dev/null; then
            print_color $GREEN "✓ Container is running successfully"
        else
            print_color $RED "✗ Container failed to start. Check logs with: $compose_cmd -f docker-compose.arm64.yaml logs"
        fi
    else
        if $compose_cmd -f docker-compose.native.yaml ps -q comfyui-native &> /dev/null; then
            print_color $GREEN "✓ Container is running successfully"
        else
            print_color $RED "✗ Container failed to start. Check logs with: $compose_cmd -f docker-compose.native.yaml logs"
        fi
    fi
}

# Function to open ComfyUI in browser
open_browser() {
    print_color $BLUE "Opening ComfyUI in your default browser..."
    sleep 2
    open "http://localhost:8188"
}

# Function to show usage
show_usage() {
    print_color $YELLOW "Usage: $0 [build|start|open|full]"
    echo ""
    echo "Commands:"
    echo "  build  - Build ComfyUI Docker image"
    echo "  start  - Start ComfyUI container"
    echo "  open   - Open ComfyUI in browser"
    echo "  full   - Build, start, and open (default)"
    echo ""
}

# Main function
main() {
    print_banner
    
    local command=${1:-full}
    
    # System checks
    check_docker
    local compose_cmd=$(check_docker_compose)
    
    # Detect system architecture
    local arch=$(detect_system)
    
    if [[ "$arch" == "unknown" ]]; then
        exit 1
    fi
    
    # Execute command
    case "$command" in
        build)
            build_comfyui "$arch" "$compose_cmd"
            ;;
        start)
            start_comfyui "$arch" "$compose_cmd"
            ;;
        open)
            open_browser
            ;;
        full)
            build_comfyui "$arch" "$compose_cmd"
            start_comfyui "$arch" "$compose_cmd"
            open_browser
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
    
    print_color $GREEN ""
    print_color $GREEN "🎉 ComfyUI setup complete!"
    print_color $GREEN "   Visit http://localhost:8188 to start creating!"
    print_color $GREEN ""
}

# Run main function
main "$@"
