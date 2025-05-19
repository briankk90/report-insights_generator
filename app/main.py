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
