# ComfyUI Docker Setup

This directory contains Docker configuration files to run ComfyUI in a containerized environment with support for multiple architectures including Apple Silicon (M1/M2/M3).

## Prerequisites

### For Linux/Windows:
- Docker and Docker Compose installed
- NVIDIA Docker runtime (for GPU support)
- NVIDIA GPU drivers installed on the host system

### For macOS (Intel/Apple Silicon):
- Docker Desktop for Mac installed
- For Apple Silicon (M1/M2/M3): Native ARM64 support with MPS acceleration
- For Intel Macs: Standard x86_64 support

## Architecture Support

This setup supports multiple architectures:

- **x86_64 with NVIDIA GPU**: Full CUDA acceleration
- **x86_64 CPU-only**: CPU inference for systems without GPU
- **ARM64 (Apple Silicon)**: Optimized for M1/M2/M3 with MPS support
- **macOS Native**: Native macOS optimization for best performance

## macOS Apple Silicon (M1/M2/M3) Setup

### Quick Start for Apple Silicon:

```bash
# Auto-detect and build for your architecture
./docker-manage.sh build

# Start ComfyUI (automatically uses ARM64 optimization on Apple Silicon)
./docker-manage.sh start

# Or explicitly use ARM64 build
./docker-manage.sh build-arm64
./docker-manage.sh start-arm64
```

### Manual Docker Commands for Apple Silicon:

```bash
# Build ARM64 image (supports both docker-compose and docker compose)
docker compose -f docker-compose.arm64.yaml build
# OR
docker-compose -f docker-compose.arm64.yaml build

# Run with ARM64 optimization
docker compose -f docker-compose.arm64.yaml up -d
# OR
docker-compose -f docker-compose.arm64.yaml up -d

# Access ComfyUI
open http://localhost:8188
```

### Installing NVIDIA Docker Support

```bash
# Install NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

## Quick Start

1. **Build and run with Docker Compose:**
   ```bash
   # Using Docker Compose v2 (recommended)
   docker compose up --build
   
   # Using Docker Compose v1 (legacy)
   docker-compose up --build
   ```

2. **Or run with Docker directly:**
   ```bash
   # Build the image
   docker build -t comfyui .
   
   # Run the container
   docker run -d \
     --name comfyui \
     --gpus all \
     -p 8188:8188 \
     -v ./models:/app/models \
     -v ./input:/app/input \
     -v ./output:/app/output \
     -v ./custom_nodes:/app/custom_nodes \
     comfyui
   ```

3. **Access ComfyUI:**
   Open your browser and navigate to `http://localhost:8188`

## Configuration

### Environment Variables

You can customize ComfyUI behavior using environment variables:

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=all
  - NVIDIA_DRIVER_CAPABILITIES=compute,utility
  - COMFYUI_LISTEN=0.0.0.0
  - COMFYUI_PORT=8188
```

### Volume Mounts

The Docker setup uses persistent volumes for:

- **Models** (`./models:/app/models`): Store your AI models
- **Input** (`./input:/app/input`): Input images and files
- **Output** (`./output:/app/output`): Generated images and outputs
- **Custom Nodes** (`./custom_nodes:/app/custom_nodes`): Custom node extensions
- **User** (`./user:/app/user`): User configurations and preferences

### Custom Model Paths

If you have an `extra_model_paths.yaml` file, it will be mounted as read-only:

```yaml
volumes:
  - ./extra_model_paths.yaml:/app/extra_model_paths.yaml:ro
```

## Usage Examples

### Basic Usage

```bash
# Start ComfyUI in the background (auto-detects docker compose command)
./docker-manage.sh start

# Or manually with Docker Compose v2
docker compose up -d

# Or with Docker Compose v1
docker-compose up -d

# View logs
./docker-manage.sh logs

# Stop ComfyUI
./docker-manage.sh stop
```

### Advanced Usage

```bash
# Run with custom arguments
./docker-manage.sh shell
# Then inside container: python3 main.py --help

# Run with CPU only (no GPU)
docker run -d \
  --name comfyui-cpu \
  -p 8188:8188 \
  -v ./models:/app/models \
  -v ./output:/app/output \
  comfyui python3 main.py --listen 0.0.0.0 --cpu

# Run with specific GPU
docker run -d \
  --name comfyui \
  --gpus '"device=0"' \
  -p 8188:8188 \
  -v ./models:/app/models \
  comfyui
```

### Development Mode

For development, you can mount the entire source code:

```bash
docker run -it \
  --name comfyui-dev \
  --gpus all \
  -p 8188:8188 \
  -v .:/app \
  comfyui bash
```

## Customization

### Custom Dockerfile

You can modify the `Dockerfile` to:

- Add additional Python packages
- Install custom system dependencies
- Configure specific CUDA versions
- Set up custom entry points

### Custom Docker Compose

The `docker-compose.yaml` includes:

- GPU support configuration
- Volume mounts for persistence
- Network configuration
- Optional reverse proxy setup (commented out)

### Adding Custom Nodes

1. Place your custom nodes in the `custom_nodes` directory
2. Rebuild the container: `docker-compose up --build`
3. Or mount the directory at runtime (already configured in compose file)

## Troubleshooting

### GPU Not Detected

```bash
# Check if NVIDIA runtime is available
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### Port Already in Use

```bash
# Change the port in docker-compose.yaml
ports:
  - "8189:8188"  # Use port 8189 instead
```

### Model Loading Issues

Ensure your models are placed in the correct subdirectories:

```
models/
├── checkpoints/
├── clip/
├── vae/
├── loras/
├── controlnet/
├── embeddings/
└── diffusion_models/
```

### Memory Issues

If you encounter out-of-memory errors:

1. Reduce batch size in your workflows
2. Use CPU fallback: `--cpu`
3. Limit GPU memory: `--reserve-vram 0.5`

## Security Considerations

- The default setup binds to all interfaces (`0.0.0.0`)
- For production, consider using a reverse proxy
- Implement proper authentication if exposing to the internet
- Regularly update the base image and dependencies

## Performance Optimization

### For Better Performance:

1. Use SSD storage for model volumes
2. Allocate sufficient GPU memory
3. Use appropriate CUDA version for your GPU
4. Consider using `--cache-lru` for model caching

### Resource Limits:

```yaml
deploy:
  resources:
    limits:
      memory: 16G
      cpus: '8'
```

## Maintenance

### Updating ComfyUI

```bash
# Pull latest code
git pull origin main

# Rebuild container (auto-detects docker compose command)
./docker-manage.sh clean
./docker-manage.sh build
./docker-manage.sh start

# Or manually with Docker Compose v2
docker compose down
docker compose up --build

# Or with Docker Compose v1
docker-compose down
docker-compose up --build
```

### Cleaning Up

```bash
# Remove containers and networks (using management script)
./docker-manage.sh clean

# Or manually with Docker Compose v2
docker compose down

# Or with Docker Compose v1
docker-compose down

# Remove images
docker rmi comfyui

# Clean up volumes (WARNING: This will delete your models)
docker compose down -v
# OR
docker-compose down -v
```

## Apple Silicon Performance Notes

### MPS (Metal Performance Shaders) Support:
- ComfyUI automatically detects and uses MPS when available
- MPS provides GPU acceleration on Apple Silicon
- Fallback to CPU if MPS is not available or encounters issues

### Memory Optimization:
- M1/M2/M3 have unified memory architecture
- Docker containers can access up to 32GB+ depending on your Mac's configuration
- Memory is shared between CPU and GPU operations

### Performance Tips for Apple Silicon:
1. **Use ARM64 optimized images**: `docker-compose.arm64.yaml`
2. **Enable MPS**: Environment variable `PYTORCH_ENABLE_MPS_FALLBACK=1`
3. **Monitor memory usage**: Use Activity Monitor to track memory consumption
4. **Use SSD storage**: Place models on fast storage for better loading times

### Troubleshooting Apple Silicon:
- If MPS fails, ComfyUI will automatically fallback to CPU
- For memory issues, reduce batch sizes or use smaller models
- Check Docker Desktop memory allocation in preferences

## Docker Platform Handling

The Docker setup properly handles different architectures:

- **Platform specification**: Defined in docker-compose files, not Dockerfiles
- **ARM64 (Apple Silicon)**: Uses `platform: linux/arm64` in docker-compose.arm64.yaml
- **Cross-platform builds**: Handled by Docker Buildx automatically
- **Best practice**: Platform flags in compose files prevent build warnings
