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
