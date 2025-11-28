# app/__init__.py

from flask import Flask
from config import Config

# --- Import shared extensions ---
from app.extensions import db, migrate, jwt, cors, api

# --- Import RESTX namespaces (Swagger-documented routes) ---
from app.core.api.routes import auth_ns, projects_ns, workers_ns, audit_ns, health_ns

def create_app():
    """
    Application factory for BuildMate.
    Creates and configures the Flask app instance.
    """
    app = Flask(__name__)

    # --- Load configuration from config.py ---
    app.config.from_object(Config)

    # --- Initialize Flask extensions ---
    db.init_app(app)         # SQLAlchemy ORM
    migrate.init_app(app, db)  # Flask-Migrate for schema migrations
    jwt.init_app(app)        # JWTManager for token-based auth
    cors.init_app(app, resources={r"/*": {"origins": app.config["CORS_ORIGINS"]}})
    api.init_app(app)        # Flask-RESTX for Swagger and API routing

    # --- Register RESTX namespaces (Swagger-documented endpoints) ---
    api.add_namespace(auth_ns, path='/auth')  # e.g. /auth/login, /auth/me
    api.add_namespace(projects_ns, path="/projects")
    api.add_namespace(workers_ns, path="/workers")
    api.add_namespace(audit_ns, path="/audit")
    api.add_namespace(health_ns, path="/health")

    # ---Health check route ---
    @app.route('/health')
    def health():
        """
        Simple health check endpoint for uptime monitoring.
        """
        return {"status": "ok"}, 200

    return app