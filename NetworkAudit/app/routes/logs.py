from flask import Blueprint, jsonify
import json
import os

logs_bp = Blueprint('logs', __name__)

@logs_bp.route('/api/dispatcher-summary', methods=['GET'])
def get_dispatcher_summary():
    path = os.path.join('..', 'Data', 'exports', 'DispatcherSummary.json')
    if os.path.exists(path):
        with open(path, 'r') as f:
            data = json.load(f)
        return jsonify(data)
    return jsonify({"error": "No dispatcher summary found"}), 404