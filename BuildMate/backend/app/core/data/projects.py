from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from app.extensions import db
from datetime import datetime

# Represents a construction project
class Project(db.Model):
    __tablename__ = 'projects'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)               # Project name
    location = Column(String(255))                           # Address or site location
    start_date = Column(DateTime, default=datetime.utcnow)   # Start date
    end_date = Column(DateTime)                              # Optional end date

    shipments = relationship("Shipment", back_populates="project")  # Linked shipments