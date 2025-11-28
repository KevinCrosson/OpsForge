# app/api/routes/__init__.py

"""
Expose RESTX namespaces for registration in app/__init__.py
"""

from .auth import auth_ns
from .projects import projects_ns
from .workers import workers_ns
from .audit import audit_ns