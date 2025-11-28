from sqlalchemy import Column, String, Integer, Float, ForeignKey
from sqlalchemy.orm import relationship
from app.extensions import db

# Represents a material or tool in inventory
class InventoryItem(db.Model):
    __tablename__ = 'inventory_items'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)               # Item name (e.g., "Rebar")
    description = Column(String(255))                        # Optional description
    quantity = Column(Integer, default=0)                    # Current stock level
    unit_price = Column(Float)                               # Price per unit
    supplier_id = Column(Integer, ForeignKey('suppliers.id'))# Link to supplier

    supplier = relationship("Supplier", back_populates="items")  # Supplier relationship

# Represents a supplier/vendor
class Supplier(db.Model):
    __tablename__ = 'suppliers'

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)               # Supplier name
    contact_email = Column(String(100))                      # Optional contact info

    items = relationship("InventoryItem", back_populates="supplier")  # Items they supply