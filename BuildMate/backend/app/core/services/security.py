# core/services/security.py

from flask_jwt_extended import get_jwt_identity
from app.models import User, Project
from flask import jsonify

def get_current_user():
    """
    Returns the current user object based on JWT identity.
    """
    user_id = get_jwt_identity()
    return User.query.get(user_id)


def require_role(*allowed_roles):
    """
    Returns a 403 response if the current user's role is not in allowed_roles.
    Usage:
        unauthorized = require_role('admin', 'manager')
        if unauthorized: return unauthorized
    """
    user = get_current_user()
    if not user or user.role.name not in allowed_roles:
        return jsonify(error="Unauthorized: insufficient role"), 403
    return None


def user_can_access_project(project_id):
    """
    Returns True if the current user is the manager of the given project.
    """
    user = get_current_user()
    project = Project.query.get(project_id)
    return project and project.manager_id == user.id


def require_project_access(project_id):
    """
    Returns a 403 response if the current user is not authorized to access the project.
    Usage:
        unauthorized = require_project_access(project_id)
        if unauthorized: return unauthorized
    """
    if not user_can_access_project(project_id):
        return jsonify(error="Access denied: project ownership required"), 403
    return None


def require_self_or_admin(target_user_id):
    """
    Returns a 403 response if the current user is not the target user or an admin.
    Useful for profile updates or sensitive actions.
    """
    user = get_current_user()
    if not user or (user.id != target_user_id and user.role.name != 'admin'):
        return jsonify(error="Access denied: not owner or admin"), 403
    return None