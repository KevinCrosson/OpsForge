# Unit test for PDF generation
from app.services import pdf_generator
import os

def test_generate_pdf():
    path = "test_output.pdf"
    pdf_generator.generate_pdf(path, "Test PDF Content")  # Generate test PDF
    assert os.path.exists(path)  # Check file exists
    os.remove(path)              # Clean up