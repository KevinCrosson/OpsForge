# app/serializers/__init__.py

from app.models import User, Role, Project, Worker, AuditLog

def serialize_user(user: User) -> dict:
    return {
        "id": user.id,
        "email": user.email,
        "name": user.name,
        "role": user.role.name if user.role else None
    }

def serialize_role(role: Role) -> dict:
    return {
        "id": role.id,
        "name": role.name
    }

def serialize_project(project: Project) -> dict:
    return {
        "id": project.id,
        "name": project.name,
        "location": project.location,
        "status": project.status,
        "start_date": project.start_date.isoformat() if project.start_date else None,
        "end_date": project.end_date.isoformat() if project.end_date else None,
        "manager": {
            "id": project.manager.id,
            "name": project.manager.name
        } if project.manager else None
    }

def serialize_worker(worker: Worker) -> dict:
    return {
        "id": worker.id,
        "name": worker.name,
        "role": worker.role,
        "photo_url": worker.photo_url,
        "last_check_in": worker.last_check_in.isoformat() if worker.last_check_in else None,
        "project_id": worker.project_id
    }

def serialize_audit_log(log: AuditLog) -> dict:
    return {
        "id": log.id,
        "user_id": log.user_id,
        "action": log.action,
        "metadata": log.metadata,
        "timestamp": log.timestamp.isoformat()
    }