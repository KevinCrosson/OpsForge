# app/core/data/models/worker.py

from app.extensions import db

class Worker(db.Model):
    """
    Represents a field worker assigned to a project.
    """
    __tablename__ = 'workers'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(50))  # e.g. electrician, plumber
    photo_url = db.Column(db.String(255))  # S3 or local path
    last_check_in = db.Column(db.DateTime)

    # Project relationship
    project_id = db.Column(db.Integer, db.ForeignKey('projects.id'), nullable=False)
    project = db.relationship('Project', back_populates='workers')