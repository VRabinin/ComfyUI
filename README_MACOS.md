# ComfyUI Docker for macOS (Apple Silicon & Intel)

This guide provides Docker configurations specifically optimized for macOS, including Apple Silicon (M1/M2/M3) and Intel processors.

## Quick Start for macOS

### 🚀 One-Command Setup:
```bash
./launch-macos.sh
```

This will automatically:
- Detect your Mac's architecture (Apple Silicon or Intel)
- Build the optimized Docker image
- Start ComfyUI with the best configuration
- Open ComfyUI in your browser

### 📋 Manual Setup:

```bash
# For Apple Silicon (M1/M2/M3)
./docker-manage.sh build-arm64
./docker-manage.sh start-arm64

# For Intel Macs
./docker-manage.sh build-native
./docker-manage.sh start-native

# Auto-detect (recommended)
./docker-manage.sh build
./docker-manage.sh start
```

## Architecture-Specific Configurations

### 🍎 Apple Silicon (M1/M2/M3) - ARM64

**Features:**
- Native ARM64 Docker container
- MPS (Metal Performance Shaders) acceleration
- Optimized for unified memory architecture
- Automatic CPU fallback if MPS fails

**Files:**
- `Dockerfile.arm64` - ARM64 optimized image
- `docker-compose.arm64.yaml` - ARM64 container configuration

**Environment Variables:**
```bash
PYTORCH_ENABLE_MPS_FALLBACK=1
PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
```

### 🖥️ Intel Macs - x86_64

**Features:**
- Native x86_64 Docker container
- CPU-optimized PyTorch
- Standard Docker configuration

**Files:**
- `Dockerfile.native` - Native macOS optimized image
- `docker-compose.native.yaml` - Native macOS container configuration

## Performance Optimization

### Apple Silicon Optimization:

1. **Memory Management:**
   ```yaml
   deploy:
     resources:
       limits:
         memory: 32G  # Adjust based on your Mac's RAM
         cpus: '12'   # M2 Max has 12 CPU cores
   ```

2. **MPS Settings:**
   - MPS is automatically detected and used when available
   - Fallback to CPU if MPS encounters issues
   - Memory is shared between CPU and GPU operations

3. **Storage:**
   - Use SSD storage for model directories
   - Mount models directory to persist between restarts

### Intel Mac Optimization:

1. **CPU Performance:**
   - Utilizes all available CPU cores
   - Optimized for x86_64 instruction set

2. **Memory:**
   - Adjust memory limits based on available RAM
   - Recommended: 16GB+ for stable operation

## Directory Structure

```
ComfyUI/
├── Dockerfile.arm64           # Apple Silicon optimized
├── Dockerfile.native          # Intel Mac optimized
├── docker-compose.arm64.yaml  # ARM64 configuration
├── docker-compose.native.yaml # Native macOS configuration
├── docker-manage.sh           # Management script
├── launch-macos.sh           # macOS quick launcher
└── models/                   # Model storage (persistent)
    ├── checkpoints/
    ├── clip/
    ├── vae/
    ├── loras/
    └── ...
```

## Usage Examples

### Basic Operations:

```bash
# Build for your architecture
./launch-macos.sh build

# Start ComfyUI
./launch-macos.sh start

# Open in browser
./launch-macos.sh open

# Full setup (build + start + open)
./launch-macos.sh full
```

### Advanced Operations:

```bash
# View logs
./docker-manage.sh logs

# Open container shell
./docker-manage.sh shell

# Check status
./docker-manage.sh status

# Stop ComfyUI
./docker-manage.sh stop

# Clean up
./docker-manage.sh clean

# Manual Docker Compose commands (both v1 and v2 supported)
docker compose -f docker-compose.arm64.yaml up -d
docker-compose -f docker-compose.arm64.yaml up -d
```

## Troubleshooting

### Common Issues:

1. **MPS Not Working (Apple Silicon):**
   ```bash
   # Check MPS availability
   python3 -c "import torch; print(torch.backends.mps.is_available())"
   
   # If MPS fails, ComfyUI will automatically fallback to CPU
   ```

2. **Memory Issues:**
   - Reduce batch sizes in workflows
   - Close other memory-intensive applications
   - Increase Docker Desktop memory allocation

3. **Docker Desktop Not Running:**
   ```bash
   # Start Docker Desktop
   open -a Docker
   ```

4. **Permission Issues:**
   ```bash
   # Fix permissions
   chmod +x docker-manage.sh
   chmod +x launch-macos.sh
   ```

### Performance Monitoring:

```bash
# Monitor container resources
docker stats

# Check system resources
top -o cpu

# Monitor Docker Desktop resources
# Open Docker Desktop → Settings → Resources
```

## Docker Desktop Settings

### Recommended Settings for macOS:

1. **Resources:**
   - **Memory:** 8GB+ (16GB+ recommended)
   - **CPU:** 4+ cores (8+ recommended)
   - **Disk:** 50GB+ free space

2. **Features:**
   - Enable "Use Rosetta for x86/amd64 emulation on Apple Silicon"
   - Enable "Use Docker Compose V2"

3. **File Sharing:**
   - Ensure the ComfyUI directory is accessible

## Model Management

### Model Storage:

```bash
# Models are stored in persistent volumes
./models/
├── checkpoints/     # Stable Diffusion models
├── clip/           # CLIP models
├── vae/            # VAE models
├── loras/          # LoRA models
├── controlnet/     # ControlNet models
└── embeddings/     # Textual Inversions
```

### Adding Models:

1. Place model files in appropriate directories
2. Restart ComfyUI if needed: `./docker-manage.sh restart`
3. Models will be automatically detected

## Security Considerations

### Network Security:
- ComfyUI runs on localhost:8188 by default
- Not exposed to external networks
- Use Docker's internal networking

### File System:
- Models and outputs are stored in mounted volumes
- Container runs with standard user permissions
- No privileged access required

## Updates and Maintenance

### Updating ComfyUI:

```bash
# Pull latest code
git pull origin main

# Rebuild and restart (auto-detects docker compose command)
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

### Cleaning Up:

```bash
# Remove containers and images
./docker-manage.sh clean

# Remove all Docker data (WARNING: removes all models)
docker system prune -a --volumes
```

## Support

### Getting Help:

1. Check Docker Desktop logs
2. View ComfyUI logs: `./docker-manage.sh logs`
3. Check container status: `./docker-manage.sh status`
4. Verify Docker installation: `docker --version`

### System Requirements:

- **macOS:** 12.0+ (Monterey or later)
- **Docker Desktop:** 4.0+ for Mac
- **RAM:** 8GB+ (16GB+ recommended)
- **Storage:** 50GB+ free space
- **Apple Silicon:** M1/M2/M3 with MPS support
- **Intel:** Core i5+ processor

## FAQ

**Q: Can I use CUDA on macOS?**
A: No, CUDA is not available on macOS. Apple Silicon uses MPS (Metal Performance Shaders) for GPU acceleration.

**Q: Which is faster, Apple Silicon or Intel Mac?**
A: Apple Silicon (M1/M2/M3) with MPS is generally faster for AI workloads compared to Intel Macs running CPU-only.

**Q: Can I run multiple instances?**
A: Yes, but change the port in docker-compose files to avoid conflicts.

**Q: How do I use custom nodes?**
A: Place custom nodes in the `custom_nodes/` directory and rebuild the container.

**Q: What about memory usage?**
A: Apple Silicon has unified memory. Monitor usage with Activity Monitor and adjust container limits accordingly.
