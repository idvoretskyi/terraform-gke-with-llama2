# Base image with JupyterLab and PyTorch (matches our ML stack)
FROM quay.io/jupyter/pytorch-notebook:python-3.11

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch with CUDA 11.8 support
RUN pip install --no-cache-dir \
    torch==2.1.2 \
    torchvision==0.16.2 \
    torchaudio==2.1.2 \
    --extra-index-url https://download.pytorch.org/whl/cu118

# Install Hugging Face Transformers and related packages
RUN pip install --no-cache-dir \
    transformers==4.36.2 \
    datasets==2.14.6 \
    accelerate==0.25.0 \
    sentencepiece==0.1.99 \
    protobuf==4.23.4

# Install jupyter-related packages
RUN pip install --no-cache-dir \
    jupyterlab==4.0.8 \
    ipywidgets==8.1.1

# Setup Llama2 model downloader
COPY download-llama2.py /opt/download-llama2.py
RUN echo "exec python /opt/download-llama2.py" > /usr/local/bin/start-notebook.d/download-llama2.sh && \
    chmod +x /usr/local/bin/start-notebook.d/download-llama2.sh

# Switch back to jovyan user
USER jovyan
