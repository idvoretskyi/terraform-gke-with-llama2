#!/usr/bin/env python3
"""Download a HuggingFace model at container startup (skip if already cached)."""

import logging
import os

from huggingface_hub import snapshot_download

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

DEFAULT_MODEL_ID = "meta-llama/Llama-2-7b-hf"


def main() -> None:
    model_id = os.environ.get("MODEL_ID", DEFAULT_MODEL_ID)
    token = os.environ.get("HUGGINGFACE_TOKEN") or None

    # snapshot_download is a no-op when the model is already cached.
    logger.info("Ensuring %s is available locally ...", model_id)
    try:
        snapshot_download(model_id, token=token)
        logger.info("Model %s ready.", model_id)
    except Exception:
        logger.exception("Failed to download %s.", model_id)
        logger.info("If access was denied, set HUGGINGFACE_TOKEN to a valid token.")


if __name__ == "__main__":
    main()
