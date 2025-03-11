#!/usr/bin/env python3

import os
import sys
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

def download_llama2():
    print("Starting Llama2 model download...")
    
    # Get Hugging Face token from environment (if set)
    hf_token = os.environ.get('HUGGINGFACE_TOKEN', '')
    
    # Model ID for Llama2-7B
    model_id = "meta-llama/Llama-2-7b-hf"
    
    try:
        # Download tokenizer
        tokenizer = AutoTokenizer.from_pretrained(model_id, use_auth_token=hf_token)
        
        # Download model with GPU support
        model = AutoModelForCausalLM.from_pretrained(
            model_id,
            torch_dtype=torch.float16,
            device_map="auto",
            use_auth_token=hf_token
        )
        
        print(f"Successfully downloaded {model_id}")
        
    except Exception as e:
        print(f"Error downloading model: {e}")
        
        # If access is denied without token
        if "401" in str(e):
            print("Access denied. You may need to provide a valid Hugging Face token.")
            print("Please set the HUGGINGFACE_TOKEN environment variable.")

if __name__ == "__main__":
    download_llama2()
