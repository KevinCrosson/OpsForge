# app/core/data/schemas/__init__.py

"""
Centralized schema imports for BuildMate.
Allows easy access to all Marshmallow schemas from a single location.
"""

from .user_schema import UserSchema
from .role_schema import RoleSchema
from .project_schema import ProjectSchema
from .worker_schema import WorkerSchema
from .audit_log_schema import AuditLogSchema

# Optional: expose schema instances for convenience
user_schema = UserSchema()
users_schema = UserSchema(many=True)

role_schema = RoleSchema()
roles_schema = RoleSchema(many=True)

project_schema = ProjectSchema()
projects_schema = ProjectSchema(many=True)

worker_schema = WorkerSchema()
workers_schema = WorkerSchema(many=True)

audit_log_schema = AuditLogSchema()
audit_logs_schema = AuditLogSchema(many=True)