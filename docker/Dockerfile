# Base image with JupyterLab and TensorFlow
FROM jupyter/tensorflow-notebook:latest

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir \
    torch torchvision torchaudio \
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

# Copy example notebook
COPY llama2-example.ipynb /home/jovyan/llama2-example.ipynb
RUN chown jovyan:users /home/jovyan/llama2-example.ipynb

# Switch back to jovyan user
USER jovyan
