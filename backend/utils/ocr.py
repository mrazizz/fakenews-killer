"""
OCR utility — extracts text from images using Gemini's multimodal vision.
No Tesseract or system dependencies required.
"""

import base64
from google import genai
from google.genai import types


class GeminiOCR:
    """Send a base64-encoded image to Gemini and get extracted text back."""

    SYSTEM_PROMPT = (
        "You are an OCR system. Extract ALL visible text from the image "
        "exactly as it appears. If the text is in Urdu, preserve the Urdu "
        "script and also provide an English translation on the next line "
        "prefixed with [EN]: . Return ONLY the extracted text."
    )

    def __init__(self, api_key: str, model: str = "gemini-2.5-flash"):
        """
        Initialise the OCR helper.

        Args:
            api_key: Google API key for Gemini.
            model:   Model name to use for vision tasks.
        """
        self.client = genai.Client(api_key=api_key)
        self.model = model

    async def extract_text(self, image_base64: str) -> str:
        """
        Extract text from a base64-encoded image using Gemini multimodal.

        Args:
            image_base64: The image encoded as a base64 string.

        Returns:
            The extracted text content as a plain string.
        """
        image_bytes = base64.b64decode(image_base64)

        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=[
                types.Content(
                    parts=[
                        types.Part.from_text(
                            "Extract all text from this image. "
                            "Preserve the original language."
                        ),
                        types.Part.from_bytes(
                            data=image_bytes, mime_type="image/jpeg"
                        ),
                    ]
                )
            ],
            config=types.GenerateContentConfig(
                system_instruction=self.SYSTEM_PROMPT,
                temperature=0.1,
            ),
        )
        return response.text.strip()
