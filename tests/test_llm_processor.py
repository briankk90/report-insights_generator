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
