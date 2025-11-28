# app/core/data/schemas/project_schema.py

from app.core.data.models.project import Project
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from marshmallow import fields
from app.core.data.schemas.user_schema import UserSchema

class ProjectSchema(SQLAlchemyAutoSchema):
    """
    Serializes and deserializes Project model instances.
    Includes nested manager and formatted dates.
    """

    class Meta:
        model = Project
        load_instance = True
        include_fk = True

    manager = fields.Nested(UserSchema, only=("id", "name"))
    start_date = fields.Date(format="iso")
    end_date = fields.Date(format="iso")