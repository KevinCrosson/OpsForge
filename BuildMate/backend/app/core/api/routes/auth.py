# app/api/routes/auth.py

from flask_restx import Namespace, Resource, fields
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app.core.data.models.user import User
from app.extensions import db
from app.core.data.schemas import user_schema

auth_ns = Namespace("auth", description="Authentication and user profile")

login_model = auth_ns.model("Login", {
    "email": fields.String(required=True, example="user@buildmate.com"),
    "password": fields.String(required=True, example="securepassword123")
})

@auth_ns.route("/login")
class Login(Resource):
    @auth_ns.expect(login_model)
    def post(self):
        """
        Authenticate user and return JWT token.
        """
        data = auth_ns.payload
        user = User.query.filter_by(email=data["email"]).first()
        if not user or not user.check_password(data["password"]):
            return {"error": "Invalid credentials"}, 401

        token = create_access_token(identity=user.id)
        return {"access_token": token}, 200

@auth_ns.route("/me")
class Profile(Resource):
    @jwt_required()
    def get(self):
        """
        Return current user's profile.
        """
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user:
            return {"error": "User not found"}, 404
        return user_schema.dump(user), 200