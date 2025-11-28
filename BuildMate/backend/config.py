# config.py

import os
from datetime import timedelta
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """
    Base configuration class for BuildMate.
    All environment-specific configs inherit from this.
    """

    # --- Flask Core ---
    SECRET_KEY = os.getenv("SECRET_KEY", "default-secret-key")  # Used for session and CSRF protection
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"

    # --- JWT Authentication ---
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "super-secret-jwt-key")  # Used to sign JWT tokens
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(seconds=int(os.getenv("JWT_ACCESS_TOKEN_EXPIRES", 3600)))  # Token lifetime

    # --- Database ---
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost:5432/buildmate_db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # Disable event system for performance

    # --- CORS ---
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*")  # Allow all origins by default

    # --- Swagger / RESTX ---
    RESTX_MASK_SWAGGER = False  # Show full Swagger models
    RESTX_VALIDATE = True       # Validate request payloads against models
    RESTX_ERROR_404_HELP = False  # Disable 404 suggestions

    # --- PDF Generation ---
    PDF_FONT = os.getenv("PDF_FONT", "Helvetica")  # Default font for reportlab
    PDF_PAGE_SIZE = os.getenv("PDF_PAGE_SIZE", "letter")  # Default page size

    # --- Logging ---
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")  # Logging level for audit and app logs
    AUDIT_LOG_PATH = os.getenv("AUDIT_LOG_PATH", "logs/audit.log")  # Path for audit logs

    # --- File Uploads ---
    UPLOAD_FOLDER = os.getenv("UPLOAD_FOLDER", "uploads/")  # Where worker photos and PDFs are stored
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # Limit uploads to 16MB

    # --- Feature Flags ---
    ENABLE_WORKER_TRACKING = os.getenv("ENABLE_WORKER_TRACKING", "true").lower() == "true"
    ENABLE_ADMIN_DASHBOARD = os.getenv("ENABLE_ADMIN_DASHBOARD", "true").lower() == "true"