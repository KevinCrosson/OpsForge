# app/utils/pdf_generator.py

from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from io import BytesIO
from app.models import Project, User
from app.utils.security import role_required

@dashboard_bp.route('/projects', methods=['GET'])
@jwt_required()
@role_required('manager')
def list_projects():
    ...

def generate_project_pdf(project_id):
    """
    Generate a PDF summary for a given project.
    Returns: PDF as bytes
    """
    project = Project.query.get(project_id)
    if not project:
        raise ValueError("Project not found")

    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    # Header
    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawString(50, height - 50, f"Project Summary: {project.name}")

    # Body
    pdf.setFont("Helvetica", 12)
    y = height - 100
    pdf.drawString(50, y, f"Location: {project.location}")
    y -= 20
    pdf.drawString(50, y, f"Status: {project.status}")
    y -= 20
    pdf.drawString(50, y, f"Start Date: {project.start_date}")
    y -= 20
    pdf.drawString(50, y, f"End Date: {project.end_date}")
    y -= 20
    pdf.drawString(50, y, f"Manager: {project.manager.name}")

    pdf.showPage()
    pdf.save()
    buffer.seek(0)
    return buffer.read()