#!/bin/bash

# Exit on any error
set -e

echo "Setting up report_insights_generator project..."

# Create directory structure
mkdir -p app configs tests

# Create empty __init__.py
touch app/__init__.py

# Copy code from artifact (assuming artifact content is available as text)
# Note: Replace the following with actual file content from the artifact
cat > app/main.py << 'EOF'
import os
import yaml
from data_ingestion import DataIngestor
from llm_processor import LLMProcessor
from report_generator import ReportGenerator
from material_tracker import MaterialTracker

def load_config(config_path):
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def main():
    config = load_config('../configs/config.yaml')
    ingestor = DataIngestor(config['data_paths'])
    llm_processor = LLMProcessor(config['azure_openai'])
    report_generator = ReportGenerator(config['report_settings'])
    material_tracker = MaterialTracker()
    csv_data, ocr_data, image_data = ingestor.process_data()
    insights = llm_processor.generate_insights(csv_data, ocr_data, image_data)
    report = report_generator.create_report(insights)
    material_status = material_tracker.track_materials(image_data, ocr_data)
    report_path = os.path.join(config['data_paths']['output'], 'daily_report.md')
    with open(report_path, 'w') as f:
        f.write(report)
    print(f"Report generated at {report_path}")
    print(f"Material tracking status: {material_status}")

if __name__ == "__main__":
    main()
EOF

cat > app/data_ingestion.py << 'EOF'
import pandas as pd
import pytesseract
import cv2
import os

class DataIngestor:
    def __init__(self, data_paths):
        self.csv_path = data_paths['csv']
        self.ocr_path = data_paths['ocr']
        self.image_path = data_paths['images']
    
    def process_data(self):
        csv_data = pd.read_csv(self.csv_path) if os.path.exists(self.csv_path) else pd.DataFrame()
        ocr_data = []
        if os.path.exists(self.ocr_path):
            with open(self.ocr_path, 'r') as f:
                ocr_data = f.readlines()
        image_data = []
        if os.path.exists(self.image_path):
            for img_file in os.listdir(self.image_path):
                img = cv2.imread(os.path.join(self.image_path, img_file))
                if img is not None:
                    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                    image_data.append(gray)
        return csv_data, ocr_data, image_data
EOF

cat > app/llm_processor.py << 'EOF'
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
EOF

cat > app/report_generator.py << 'EOF'
import datetime

class ReportGenerator:
    def __init__(self, settings):
        self.output_format = settings['format']
    
    def create_report(self, insights):
        date = datetime.datetime.now().strftime("%Y-%m-%d")
        report = f"# Daily Insights Report - {date}\n\n"
        report += "## Key Insights\n"
        report += insights
        return report
EOF

cat > app/material_tracker.py << 'EOF'
class MaterialTracker:
    def track_materials(self, image_data, ocr_data):
        material_count = len(image_data)
        ocr_mentions = sum(1 for text in ocr_data if "material" in text.lower())
        return f"Tracked {material_count} material images, {ocr_mentions} OCR mentions"
EOF

cat > configs/config.yaml << 'EOF'
data_paths:
  csv: "/dbfs/mnt/data/csv/input.csv"
  ocr: "/dbfs/mnt/data/ocr/text.txt"
  images: "/dbfs/mnt/data/images/"
  output: "/dbfs/mnt/data/output/"
azure_openai:
  api_key: "your_azure_openai_api_key"
  api_version: "2023-07-01-preview"
  endpoint: "https://your-resource-name.openai.azure.com/"
report_settings:
  format: "markdown"
EOF

cat > tests/test_data_ingestion.py << 'EOF'
import unittest
from app.data_ingestion import DataIngestor

class TestDataIngestor(unittest.TestCase):
    def test_process_data(self):
        paths = {
            'csv': 'nonexistent.csv',
            'ocr': 'nonexistent.txt',
            'images': 'nonexistent/'
        }
        ingestor = DataIngestor(paths)
        csv_data, ocr_data, image_data = ingestor.process_data()
        self.assertTrue(csv_data.empty)
        self.assertEqual(ocr_data, [])
        self.assertEqual(image_data, [])

if __name__ == '__main__':
    unittest.main()
EOF

cat > tests/test_llm_processor.py << 'EOF'
import unittest
from unittest.mock import patch
from app.llm_processor import LLMProcessor

class TestLLMProcessor(unittest.TestCase):
    @patch('app.llm_processor.AzureOpenAI')
    def test_generate_insights(self, mock_openai):
        mock_openai.return_value.chat.completions.create.return_value.choices[0].message.content = "Mocked insights"
        processor = LLMProcessor({
            'api_key': 'test',
            'api_version': 'test',
            'endpoint': 'test'
        })
        insights = processor.generate_insights(pd.DataFrame(), [], [])
        self.assertEqual(insights, "Mocked insights")

if __name__ == '__main__':
    unittest.main()
EOF

cat > requirements.txt << 'EOF'
pandas==2.0.3
pytesseract==0.3.10
opencv-python==4.8.0
pyyaml==6.0
openai==1.30.0
EOF

cat > README.md << 'EOF'
# Report Insights Generator

A Gen AI-powered tool for generating daily insights reports from CSV, OCR, and image data, deployable on Databricks.

## Setup
1. Install dependencies: `pip install -r requirements.txt`
2. Configure `configs/config.yaml` with your Azure OpenAI credentials and data paths.
3. Run the application: `python app/main.py`

## Features
- Ingests CSV, OCR, and image data
- Generates insights using Azure OpenAI
- Produces Markdown reports
- Tracks material movement (basic implementation)

## Deployment on Databricks
1. Upload the project to a Databricks workspace.
2. Configure blob storage paths in `config.yaml`.
3. Run `main.py` on a Databricks cluster.

## Testing
Run tests with: `python -m unittest discover tests`
EOF

# Install dependencies (assuming Python and pip are available)
echo "Installing dependencies..."
pip install -r requirements.txt

# Create dummy data for testing (since actual data paths are Databricks-specific)
echo "Creating dummy data..."
mkdir -p data/csv data/ocr data/images data/output
touch data/csv/input.csv
echo "Sample OCR text" > data/ocr/text.txt

# Update config.yaml for local testing
cat > configs/config.yaml << 'EOF'
data_paths:
  csv: "data/csv/input.csv"
  ocr: "data/ocr/text.txt"
  images: "data/images/"
  output: "data/output/"
azure_openai:
  api_key: "your_azure_openai_api_key"
  api_version: "2023-07-01-preview"
  endpoint: "https://your-resource-name.openai.azure.com/"
report_settings:
  format: "markdown"
EOF

# Run tests
echo "Running tests..."
python -m unittest discover tests

# Run the application
echo "Running the application..."
python app/main.py

echo "Setup and execution complete!"