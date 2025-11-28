# app/api/routes/workers.py

from flask_restx import Namespace, Resource
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.core.data.models.project import Project
from app.core.data.models.worker import Worker
from app.core.data.schemas import workers_schema

workers_ns = Namespace("workers", description="Worker tracking")

@workers_ns.route("/")
class WorkerList(Resource):
    @jwt_required()
    def get(self):
        """
        List all workers across the user's projects.
        """
        user_id = get_jwt_identity()
        projects = Project.query.filter_by(manager_id=user_id).all()
        project_ids = [p.id for p in projects]
        workers = Worker.query.filter(Worker.project_id.in_(project_ids)).all()
        return workers_schema.dump(workers), 200