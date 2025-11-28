# app/core/data/schemas/user_schema.py

from app.core.data.models.user import User
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from marshmallow import fields
from app.core.data.schemas.role_schema import RoleSchema

class UserSchema(SQLAlchemyAutoSchema):
    """
    Serializes and deserializes User model instances.
    Includes nested role and excludes password hash.
    """

    class Meta:
        model = User
        load_instance = True
        include_fk = True
        exclude = ("password_hash",)

    role = fields.Nested(RoleSchema)