# PyTorch + JupyterLab base image (includes torch, jupyterlab, and build-essential)
FROM quay.io/jupyter/pytorch-notebook:python-3.11

USER root

# Install git and curl (not in base image)
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install HuggingFace stack
RUN pip install --no-cache-dir \
    transformers==4.36.2 \
    datasets==2.14.6 \
    accelerate==0.25.0 \
    sentencepiece==0.1.99 \
    protobuf==4.23.4 \
    huggingface_hub

# Setup model downloader (runs on first notebook start)
COPY download-llama2.py /opt/download-llama2.py
RUN echo "exec python /opt/download-llama2.py" > /usr/local/bin/start-notebook.d/download-llama2.sh && \
    chmod +x /usr/local/bin/start-notebook.d/download-llama2.sh

USER jovyan
