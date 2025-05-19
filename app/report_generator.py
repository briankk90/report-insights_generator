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
