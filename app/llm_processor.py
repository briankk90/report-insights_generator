from openai import AzureOpenAI
import pandas as pd

class LLMProcessor:
    def __init__(self, azure_config):
        self.client = AzureOpenAI(
            api_key=azure_config['api_key'],
            api_version=azure_config['api_version'],
            azure_endpoint=azure_config['endpoint']
        )
    
    def generate_insights(self, csv_data, ocr_data, image_data):
        csv_summary = csv_data.describe().to_string() if not csv_data.empty else "No CSV data"
        ocr_text = " ".join(ocr_data) if ocr_data else "No OCR data"
        image_info = f"{len(image_data)} images processed" if image_data else "No image data"
        prompt = f"""
        Generate actionable insights based on the following data:
        - CSV Data Summary: {csv_summary}
        - OCR Extracted Text: {ocr_text}
        - Image Data: {image_info}
        Provide a concise report with 3-5 key insights.
        """
        response = self.client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=500
        )
        return response.choices[0].message.content
