# app/core/data/models/project.py

from app.extensions import db

class Project(db.Model):
    """
    Represents a construction project managed by a user.
    """
    __tablename__ = 'projects'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(150))
    status = db.Column(db.String(50))
    start_date = db.Column(db.Date)
    end_date = db.Column(db.Date)

    # Manager relationship
    manager_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    manager = db.relationship('User', back_populates='managed_projects')

    # Workers assigned to this project
    workers = db.relationship('Worker', back_populates='project', lazy='dynamic')