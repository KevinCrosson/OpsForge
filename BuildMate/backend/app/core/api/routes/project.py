# app/api/routes/projects.py

from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.core.data.models.project import Project
from app.core.data.schemas import projects_schema

projects_ns = Namespace("projects", description="Project management")

@projects_ns.route("/")
class ProjectList(Resource):
    @jwt_required()
    def get(self):
        """
        List all projects managed by the current user.
        """
        user_id = get_jwt_identity()
        projects = Project.query.filter_by(manager_id=user_id).all()
        return projects_schema.dump(projects), 200