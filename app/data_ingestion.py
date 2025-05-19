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
