# app/core/data/schemas/worker_schema.py

from app.core.data.models.worker import Worker
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from marshmallow import fields

class WorkerSchema(SQLAlchemyAutoSchema):
    """
    Serializes and deserializes Worker model instances.
    Includes formatted check-in timestamp.
    """

    class Meta:
        model = Worker
        load_instance = True
        include_fk = True

    last_check_in = fields.DateTime(format="iso")