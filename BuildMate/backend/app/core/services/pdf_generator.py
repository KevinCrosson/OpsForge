# PDF generation using ReportLab
from reportlab.pdfgen import canvas

def generate_pdf(output_path, content):
    c = canvas.Canvas(output_path)      # Create canvas
    c.drawString(100, 750, content)     # Draw text at position
    c.save()                            # Save PDF file