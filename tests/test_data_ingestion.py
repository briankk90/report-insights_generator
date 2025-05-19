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
