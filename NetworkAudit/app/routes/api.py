from flask import Blueprint, jsonify
import os, json

api = Blueprint('api', __name__)

@api.route('/api/active-connections')
def get_active_connections():
    path = os.path.join('Logs', 'ActiveConnections-LATEST.json')
    if os.path.exists(path):
        with open(path) as f:
            return jsonify(json.load(f))
    return jsonify({"error": "No connection log found"}), 404