#!/usr/bin/env python3
"""Download Llama2 model from HuggingFace at container startup.

Checks for an existing cached model before downloading. The model ID
and HuggingFace token are configurable via environment variables.
"""

import logging
import os

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

# Defaults
DEFAULT_MODEL_ID = "meta-llama/Llama-2-7b-hf"
DEFAULT_CACHE_DIR = os.path.expanduser("~/.cache/huggingface/hub")


def _model_is_cached(model_id: str, cache_dir: str) -> bool:
    """Return True if the model directory already exists in the cache."""
    model_dir_name = "models--" + model_id.replace("/", "--")
    return os.path.isdir(os.path.join(cache_dir, model_dir_name))


def download_llama2() -> None:
    """Download the Llama2 model and tokenizer if not already cached."""
    model_id = os.environ.get("MODEL_ID", DEFAULT_MODEL_ID)
    hf_token = os.environ.get("HUGGINGFACE_TOKEN") or None
    cache_dir = os.environ.get("HF_HOME", DEFAULT_CACHE_DIR)

    if _model_is_cached(model_id, cache_dir):
        logger.info("Model %s is already cached -- skipping download.", model_id)
        return

    logger.info("Starting download of %s ...", model_id)

    try:
        tokenizer = AutoTokenizer.from_pretrained(model_id, token=hf_token)
        model = AutoModelForCausalLM.from_pretrained(
            model_id,
            torch_dtype=torch.float16,
            device_map="auto",
            token=hf_token,
        )
        logger.info("Successfully downloaded %s", model_id)

    except Exception:
        logger.exception("Failed to download model %s.", model_id)
        logger.info(
            "If access was denied, set the HUGGINGFACE_TOKEN environment variable "
            "to a valid HuggingFace access token."
        )


if __name__ == "__main__":
    download_llama2()
