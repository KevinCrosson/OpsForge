# app/core/data/models/audit_log.py

from app.extensions import db
from datetime import datetime

class AuditLog(db.Model):
    """
    Logs sensitive user actions for compliance and traceability.
    """
    __tablename__ = 'audit_logs'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    action = db.Column(db.String(100), nullable=False)
    metadata = db.Column(db.JSON)  # Optional context (e.g. project_id, IP address)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    # User relationship
    user = db.relationship('User', back_populates='audit_logs')