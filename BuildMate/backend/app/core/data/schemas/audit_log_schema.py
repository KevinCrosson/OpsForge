# app/core/data/schemas/audit_log_schema.py

from app.core.data.models.audit_log import AuditLog
from marshmallow_sqlalchemy import SQLAlchemyAutoSchema
from marshmallow import fields

class AuditLogSchema(SQLAlchemyAutoSchema):
    """
    Serializes and deserializes AuditLog entries.
    Used for compliance and traceability.
    """

    class Meta:
        model = AuditLog
        load_instance = True
        include_fk = True

    timestamp = fields.DateTime(format="iso")