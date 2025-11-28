# app/core/data/models/user.py

from app.extensions import db
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    """
    Represents a system user (admin, manager, contractor).
    """
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    name = db.Column(db.String(100), nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)

    # Role relationship
    role_id = db.Column(db.Integer, db.ForeignKey('roles.id'), nullable=False)
    role = db.relationship('Role', back_populates='users')

    # Audit logs and managed projects
    audit_logs = db.relationship('AuditLog', back_populates='user', lazy='dynamic')
    managed_projects = db.relationship('Project', back_populates='manager', lazy='dynamic')

    def set_password(self, password):
        """
        Hash and store the user's password.
        """
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """
        Verify a password against the stored hash.
        """
        return check_password_hash(self.password_hash, password)