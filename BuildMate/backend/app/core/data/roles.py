from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.extensions import db

# Represents a user role (e.g., Admin, Worker)
class Role(db.Model):
    __tablename__ = 'roles'

    id = Column(Integer, primary_key=True)
    name = Column(String(50), unique=True, nullable=False)   # Role name
    description = Column(String(255))                        # Optional description

    users = relationship("User", back_populates="role")      # Users with this role

# Represents a system user (simplified for role mapping)
class User(db.Model):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    username = Column(String(100), unique=True, nullable=False)
    role_id = Column(Integer, ForeignKey('roles.id'))        # Assigned role

    role = relationship("Role", back_populates="users")      # Role relationship