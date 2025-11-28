# app/core/data/models/role.py

from app.extensions import db

class Role(db.Model):
    """
    Represents a user role (admin, manager, contractor).
    """
    __tablename__ = 'roles'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)

    # Users with this role
    users = db.relationship('User', back_populates='role', lazy='dynamic')