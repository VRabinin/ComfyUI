# Docker Compose v2 Compatibility Update

## Summary of Changes

This document summarizes the updates made to support both Docker Compose v1 (`docker-compose`) and v2 (`docker compose`) commands across all ComfyUI Docker scripts.

## Problem

The newer versions of Docker now use `docker compose` (v2) instead of `docker-compose` (v1). Users with newer Docker installations were unable to use the scripts because they were hardcoded to use `docker-compose`.

## Solution

Updated all scripts to automatically detect and use the best available Docker Compose command:

1. **First priority**: `docker compose` (v2, recommended)
2. **Fallback**: `docker-compose` (v1, legacy)
3. **Error**: If neither is available, show helpful error message

## Files Modified

### 1. `docker-manage.sh` - Main Management Script
- **Added**: `get_docker_compose_cmd()` function for automatic detection
- **Updated**: All function calls to use the detected command
- **Added**: Docker Compose support information in help text
- **Enhanced**: Error handling for missing Docker Compose

### 2. `launch-macos.sh` - macOS Quick Launcher
- **Updated**: `check_docker_compose()` function to detect both versions
- **Modified**: `build_comfyui()` and `start_comfyui()` functions to accept compose command parameter
- **Enhanced**: Better error messages and version detection feedback

### 3. `DOCKER_README.md` - Main Documentation
- **Updated**: All examples to show both `docker compose` and `docker-compose` syntax
- **Added**: Notes about v1 vs v2 compatibility
- **Enhanced**: Installation and usage instructions

### 4. `README_MACOS.md` - macOS-Specific Documentation
- **Updated**: All Docker Compose examples to show both versions
- **Added**: Compatibility notes for macOS users
- **Enhanced**: Troubleshooting section

### 5. `test-docker-setup.sh` - New Compatibility Test Script
- **Created**: Comprehensive test script to verify Docker setup
- **Features**: Tests both Docker Compose versions
- **Includes**: Architecture detection, macOS detection, and recommendations

## Technical Implementation

### Detection Logic
```bash
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
```

### Usage in Scripts
```bash
# Get the appropriate command
COMPOSE_CMD=$(get_docker_compose_cmd)

# Use it in function calls
$COMPOSE_CMD -f docker-compose.arm64.yaml build
$COMPOSE_CMD -f docker-compose.arm64.yaml up -d
```

## Benefits

1. **Backward Compatibility**: Works with older Docker installations using `docker-compose`
2. **Forward Compatibility**: Automatically uses newer `docker compose` when available
3. **User-Friendly**: No manual configuration required
4. **Error Prevention**: Clear error messages when Docker Compose is missing
5. **Documentation**: Updated examples show both syntaxes

## Testing

The `test-docker-setup.sh` script provides comprehensive testing:

- ✓ Docker installation check
- ✓ Docker daemon status
- ✓ Docker Compose v1 detection
- ✓ Docker Compose v2 detection
- ✓ Architecture detection (ARM64/x86_64)
- ✓ macOS detection
- ✓ Command functionality test

## Usage Examples

### Automatic Detection (Recommended)
```bash
./docker-manage.sh build
./docker-manage.sh start
```

### Manual Commands (Both Supported)
```bash
# Docker Compose v2 (newer)
docker compose -f docker-compose.arm64.yaml up -d

# Docker Compose v1 (legacy)
docker-compose -f docker-compose.arm64.yaml up -d
```

## Verification Commands

Test your setup with these commands:

```bash
# Test Docker Compose compatibility
./test-docker-setup.sh

# Test script functionality
./docker-manage.sh help

# Test macOS launcher
./launch-macos.sh help
```

## Migration Path

For users upgrading from older Docker versions:

1. **No action required** - Scripts automatically detect the available command
2. **Recommended**: Update to Docker Desktop with Compose v2 for better performance
3. **Legacy users**: Continue using `docker-compose` - still supported

## Error Handling

The scripts now provide clear error messages for common issues:

- Missing Docker Compose installation
- Docker daemon not running
- Architecture not supported
- Container startup failures

## Future Considerations

- **Docker Compose v1 EOL**: When Docker Compose v1 reaches end-of-life, can easily remove fallback
- **New Docker features**: Easy to add support for future Docker Compose enhancements
- **Performance**: Scripts prefer v2 for better performance when available

## Conclusion

All ComfyUI Docker scripts now support both Docker Compose v1 and v2, ensuring compatibility across different Docker installations while providing a smooth user experience with automatic detection and clear error messages.
