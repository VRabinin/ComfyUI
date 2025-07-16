#!/bin/bash

# ComfyUI Docker Management Script with Docker Compose v2 support

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_color $RED "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to detect docker compose command
get_docker_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null 2>&1; then
        echo "docker compose"
    else
        print_color $RED "Neither 'docker-compose' nor 'docker compose' found. Please install Docker Compose."
        exit 1
    fi
}

# Function to check if NVIDIA Docker is available
check_nvidia_docker() {
    if ! docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi > /dev/null 2>&1; then
        print_color $YELLOW "NVIDIA Docker runtime not available. GPU support will be disabled."
        return 1
    fi
    return 0
}

# Function to detect system architecture
detect_arch() {
    case "$(uname -m)" in
        arm64|aarch64)
            echo "arm64"
            ;;
        x86_64|amd64)
            echo "x86_64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Function to detect if running on macOS
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# Help function
show_help() {
    cat << EOF
ComfyUI Docker Management Script

Usage: $0 [COMMAND]

Commands:
    build           Build the ComfyUI Docker image (auto-detects architecture)
    build-cpu       Build the CPU-only ComfyUI Docker image
    build-arm64     Build the ARM64/Apple Silicon optimized image
    build-native    Build the native macOS optimized image
    start           Start ComfyUI (auto-detects best configuration)
    start-cpu       Start ComfyUI with CPU-only support
    start-arm64     Start ComfyUI with ARM64/Apple Silicon optimization
    start-native    Start ComfyUI with native macOS optimization
    stop            Stop ComfyUI
    restart         Restart ComfyUI
    logs            Show ComfyUI logs
    shell           Open a shell in the ComfyUI container
    status          Show container status
    clean           Clean up containers and images
    help            Show this help message

Examples:
    $0 build        # Build the appropriate image for your system
    $0 start        # Start ComfyUI with optimal settings
    $0 start-arm64  # Start with ARM64 optimization (M1/M2 Macs)
    $0 logs         # View the logs
    $0 stop         # Stop ComfyUI

Docker Compose Support:
    This script automatically detects and uses the best available Docker Compose command:
    - docker compose (v2, recommended)
    - docker-compose (v1, legacy)
EOF
}

# Build function
build_image() {
    print_color $GREEN "Building ComfyUI Docker image..."
    
    # Auto-detect architecture and OS
    ARCH=$(detect_arch)
    COMPOSE_CMD=$(get_docker_compose_cmd)
    
    if is_macos && [[ "$ARCH" == "arm64" ]]; then
        print_color $YELLOW "Detected macOS ARM64 (Apple Silicon) - using optimized build"
        $COMPOSE_CMD -f docker-compose.arm64.yaml build
    elif is_macos; then
        print_color $YELLOW "Detected macOS x86_64 - using native build"
        $COMPOSE_CMD -f docker-compose.native.yaml build
    else
        # Linux or other systems
        $COMPOSE_CMD build
    fi
    
    print_color $GREEN "Build completed successfully!"
}

# Build CPU function
build_cpu_image() {
    print_color $GREEN "Building ComfyUI CPU-only Docker image..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.cpu.yaml build
    print_color $GREEN "CPU build completed successfully!"
}

# Build ARM64 function
build_arm64_image() {
    print_color $GREEN "Building ComfyUI ARM64/Apple Silicon Docker image..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.arm64.yaml build
    print_color $GREEN "ARM64 build completed successfully!"
}

# Build native macOS function
build_native_image() {
    print_color $GREEN "Building ComfyUI native macOS Docker image..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.native.yaml build
    print_color $GREEN "Native macOS build completed successfully!"
}

# Start function
start_comfyui() {
    check_docker
    
    # Auto-detect best configuration
    ARCH=$(detect_arch)
    COMPOSE_CMD=$(get_docker_compose_cmd)
    
    if is_macos && [[ "$ARCH" == "arm64" ]]; then
        print_color $GREEN "Starting ComfyUI with ARM64/Apple Silicon optimization..."
        $COMPOSE_CMD -f docker-compose.arm64.yaml up -d
        print_color $GREEN "ComfyUI is starting up with MPS support..."
    elif is_macos; then
        print_color $GREEN "Starting ComfyUI with native macOS optimization..."
        $COMPOSE_CMD -f docker-compose.native.yaml up -d
        print_color $GREEN "ComfyUI is starting up with native optimization..."
    else
        # Linux systems - check for GPU support
        if check_nvidia_docker; then
            print_color $GREEN "Starting ComfyUI with GPU support..."
            $COMPOSE_CMD up -d
        else
            print_color $YELLOW "Starting ComfyUI in CPU-only mode..."
            $COMPOSE_CMD -f docker-compose.cpu.yaml up -d
        fi
    fi
    
    print_color $GREEN "Access ComfyUI at: http://localhost:8188"
}

# Start CPU function
start_cpu_comfyui() {
    check_docker
    print_color $GREEN "Starting ComfyUI in CPU-only mode..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.cpu.yaml up -d
    print_color $GREEN "ComfyUI is starting up..."
    print_color $GREEN "Access ComfyUI at: http://localhost:8188"
}

# Start ARM64 function
start_arm64_comfyui() {
    check_docker
    print_color $GREEN "Starting ComfyUI with ARM64/Apple Silicon optimization..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.arm64.yaml up -d
    print_color $GREEN "ComfyUI is starting up with ARM64 optimization..."
    print_color $GREEN "Access ComfyUI at: http://localhost:8188"
}

# Start native macOS function
start_native_comfyui() {
    check_docker
    print_color $GREEN "Starting ComfyUI with native macOS optimization..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD -f docker-compose.native.yaml up -d
    print_color $GREEN "ComfyUI is starting up with native macOS optimization..."
    print_color $GREEN "Access ComfyUI at: http://localhost:8188"
}

# Stop function
stop_comfyui() {
    print_color $YELLOW "Stopping ComfyUI..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD down 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.cpu.yaml down 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.arm64.yaml down 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.native.yaml down 2>/dev/null || true
    print_color $GREEN "ComfyUI stopped successfully!"
}

# Restart function
restart_comfyui() {
    stop_comfyui
    start_comfyui
}

# Logs function
show_logs() {
    COMPOSE_CMD=$(get_docker_compose_cmd)
    if $COMPOSE_CMD ps -q comfyui > /dev/null 2>&1; then
        $COMPOSE_CMD logs -f comfyui
    elif $COMPOSE_CMD -f docker-compose.cpu.yaml ps -q comfyui-cpu > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.cpu.yaml logs -f comfyui-cpu
    elif $COMPOSE_CMD -f docker-compose.arm64.yaml ps -q comfyui-m2 > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.arm64.yaml logs -f comfyui-m2
    elif $COMPOSE_CMD -f docker-compose.native.yaml ps -q comfyui-native > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.native.yaml logs -f comfyui-native
    else
        print_color $RED "No ComfyUI container is running."
    fi
}

# Shell function
open_shell() {
    COMPOSE_CMD=$(get_docker_compose_cmd)
    if $COMPOSE_CMD ps -q comfyui > /dev/null 2>&1; then
        $COMPOSE_CMD exec comfyui bash
    elif $COMPOSE_CMD -f docker-compose.cpu.yaml ps -q comfyui-cpu > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.cpu.yaml exec comfyui-cpu bash
    elif $COMPOSE_CMD -f docker-compose.arm64.yaml ps -q comfyui-m2 > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.arm64.yaml exec comfyui-m2 bash
    elif $COMPOSE_CMD -f docker-compose.native.yaml ps -q comfyui-native > /dev/null 2>&1; then
        $COMPOSE_CMD -f docker-compose.native.yaml exec comfyui-native bash
    else
        print_color $RED "No ComfyUI container is running."
    fi
}

# Status function
show_status() {
    print_color $GREEN "ComfyUI Container Status:"
    echo "=========================="
    COMPOSE_CMD=$(get_docker_compose_cmd)
    echo "GPU/Linux containers:"
    $COMPOSE_CMD ps 2>/dev/null || true
    echo "CPU-only containers:"
    $COMPOSE_CMD -f docker-compose.cpu.yaml ps 2>/dev/null || true
    echo "ARM64/Apple Silicon containers:"
    $COMPOSE_CMD -f docker-compose.arm64.yaml ps 2>/dev/null || true
    echo "Native macOS containers:"
    $COMPOSE_CMD -f docker-compose.native.yaml ps 2>/dev/null || true
}

# Clean function
clean_up() {
    print_color $YELLOW "Cleaning up ComfyUI containers and images..."
    COMPOSE_CMD=$(get_docker_compose_cmd)
    $COMPOSE_CMD down --remove-orphans 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.cpu.yaml down --remove-orphans 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.arm64.yaml down --remove-orphans 2>/dev/null || true
    $COMPOSE_CMD -f docker-compose.native.yaml down --remove-orphans 2>/dev/null || true
    
    # Remove images
    docker rmi comfyui_comfyui 2>/dev/null || true
    docker rmi comfyui_comfyui-cpu 2>/dev/null || true
    docker rmi comfyui_comfyui-m2 2>/dev/null || true
    docker rmi comfyui_comfyui-native 2>/dev/null || true
    
    print_color $GREEN "Cleanup completed!"
}

# Main script logic
case "${1:-help}" in
    build)
        build_image
        ;;
    build-cpu)
        build_cpu_image
        ;;
    build-arm64)
        build_arm64_image
        ;;
    build-native)
        build_native_image
        ;;
    start)
        start_comfyui
        ;;
    start-cpu)
        start_cpu_comfyui
        ;;
    start-arm64)
        start_arm64_comfyui
        ;;
    start-native)
        start_native_comfyui
        ;;
    stop)
        stop_comfyui
        ;;
    restart)
        restart_comfyui
        ;;
    logs)
        show_logs
        ;;
    shell)
        open_shell
        ;;
    status)
        show_status
        ;;
    clean)
        clean_up
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_color $RED "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
