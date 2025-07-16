# Use NVIDIA CUDA base image for GPU support
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV HF_HUB_DISABLE_TELEMETRY=1
ENV DO_NOT_TRACK=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    ffmpeg \
    libsm6 \
    libxext6 \
    libfontconfig1 \
    libxrender1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgomp1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create symbolic link for python
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Upgrade pip
RUN pip3 install --upgrade pip

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies and PyTorch in a single layer to reduce space usage
RUN pip3 install --no-cache-dir -r requirements.txt && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 cache purge && \
    rm -rf /tmp/* /var/tmp/* ~/.cache/pip

# Copy the application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/models/checkpoints \
    /app/models/clip \
    /app/models/vae \
    /app/models/loras \
    /app/models/controlnet \
    /app/models/embeddings \
    /app/models/diffusion_models \
    /app/input \
    /app/output \
    /app/temp \
    /app/user \
    /app/custom_nodes

# Set permissions
RUN chmod -R 755 /app

# Expose the port ComfyUI runs on
EXPOSE 8188

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8188/ || exit 1

# Default command
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
