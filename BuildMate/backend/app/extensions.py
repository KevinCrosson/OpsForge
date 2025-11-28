from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_restx import Api

api = Api(doc="/docs")  # Swagger UI available at /docs

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
cors = CORS()
api = Api(
    title="BuildMate API",
    version="1.0",
    description="Construction tech endpoints for project managers and contractors"
)