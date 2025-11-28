import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    # Flask settings
    DEBUG = os.getenv('FLASK_DEBUG', 'False') == 'True'     # Enable debug mode if FLASK_DEBUG=True
    SECRET_KEY = os.getenv('SECRET_KEY', 'super-secret')    # Used for session and JWT encryption

    # SQLAlchemy settings
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'postgresql://user:pass@localhost/buildmate_db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False                  # Disable event system for performance

    # JWT settings
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'jwt-secret')  # Used to sign JWT tokens

    # CORS settings
    CORS_HEADERS = 'Content-Type'                           # Allow Content-Type headers in CORS

    # Optional: Upload folder for photos
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', '/tmp/uploads')

    # Optional: S3 integration
    S3_BUCKET = os.getenv('S3_BUCKET')
    S3_ACCESS_KEY = os.getenv('S3_ACCESS_KEY')
    S3_SECRET_KEY = os.getenv('S3_SECRET_KEY')
    S3_REGION = os.getenv('S3_REGION', 'us-east-1')