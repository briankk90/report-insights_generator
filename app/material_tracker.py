class MaterialTracker:
    def track_materials(self, image_data, ocr_data):
        material_count = len(image_data)
        ocr_mentions = sum(1 for text in ocr_data if "material" in text.lower())
        return f"Tracked {material_count} material images, {ocr_mentions} OCR mentions"
