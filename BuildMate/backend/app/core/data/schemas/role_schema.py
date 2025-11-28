# app/core/data/schemas/role_schema.py

from app.core.data.models.role import Role
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema

class RoleSchema(SQLAlchemyAutoSchema):
    """
    Serializes and deserializes Role model instances.
    """

    class Meta:
        model = Role
        load_instance = True