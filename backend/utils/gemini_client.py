"""
Resilient Gemini Client — Handles fallback to alternative models
when primary models hit rate limits, quota limits, or other API errors.
"""

import os
import logging
from google import genai
from google.genai import types

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("fakenews_killer.gemini_client")

# Ordered list of text models to try when out of limits
FALLBACK_MODELS = [
    "gemini-2.5-flash",
    "gemini-3-flash",
    "gemini-3.1-flash-lite",
    "gemini-2.5-flash-lite",
    "gemini-2-flash",
    "gemini-2.0-flash",
    "gemini-1.5-flash",
]

async def generate_content_with_fallback(
    contents,
    config: types.GenerateContentConfig,
    client: genai.Client = None,
    preferred_models: list[str] = None
):
    """
    Generate content with automatic fallback to secondary models if the primary model fails.
    
    Args:
        contents: The prompt / contents for the model.
        config: The GenerateContentConfig instance.
        client: Optional genai.Client instance. If not provided, a new one will be created.
        preferred_models: Optional list of model strings to try in order. Defaults to FALLBACK_MODELS.
        
    Returns:
        A tuple of (response, successful_model_name).
    """
    if not client:
        api_key = os.environ.get("GOOGLE_API_KEY")
        client = genai.Client(api_key=api_key)
        
    models_to_try = preferred_models or FALLBACK_MODELS
    
    last_error = None
    for model in models_to_try:
        try:
            logger.info(f"Generating content with model '{model}'...")
            
            # Using client.aio.models.generate_content for asynchronous execution
            response = await client.aio.models.generate_content(
                model=model,
                contents=contents,
                config=config
            )
            
            logger.info(f"Success! Model '{model}' successfully responded.")
            return response, model
            
        except Exception as e:
            last_error = e
            logger.warning(
                f"Model '{model}' failed (Quota/Limit/Error). Exception: {e}. "
                f"Trying fallback model..."
            )
            continue
            
    # If we tried everything and failed, raise the final error
    logger.error("All configured Gemini models failed.")
    raise last_error if last_error else Exception("All Gemini models failed.")
