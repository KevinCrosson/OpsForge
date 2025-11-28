from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.extensions import db
from datetime import datetime

# Represents a shipment linked to a project
class Shipment(db.Model):
    __tablename__ = 'shipments'

    id = Column(Integer, primary_key=True)
    tracking_number = Column(String(100), unique=True)       # Carrier tracking ID
    project_id = Column(Integer, ForeignKey('projects.id'))  # Destination project
    status = Column(String(50), default='Pending')           # Status: Pending, In Transit, Delivered
    eta = Column(DateTime)                                   # Estimated arrival time
    confirmed = Column(Boolean, default=False)               # Delivery confirmed?

    project = relationship("Project", back_populates="shipments")  # Link to project