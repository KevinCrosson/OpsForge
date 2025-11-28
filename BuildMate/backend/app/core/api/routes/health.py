from flask_restx import Namespace, Resource

health_ns = Namespace("health", description="Health check endpoint")

@health_ns.route("/")
class HealthCheck(Resource):
    def get(self):
        """
        Basic health check to confirm API is running.
        """
        return {"status": "ok"}, 200