# app/utils/security.py

from functools import wraps
from flask_jwt_extended import get_jwt_identity
from flask import jsonify
from app.models import User

def role_required(*roles):
    """
    Restrict access to users with specific roles.
    Usage: @role_required('admin', 'manager')
    """
    def wrapper(fn):
        @wraps(fn)
        def decorated(*args, **kwargs):
            user = User.query.get(get_jwt_identity())
            if user.role.name not in roles:
                return jsonify(error="Unauthorized"), 403
            return fn(*args, **kwargs)
        return decorated
    return wrapper