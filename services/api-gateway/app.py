"""
API Gateway Service
Routes requests to appropriate microservices and handles authentication
"""
from flask import Flask, request, jsonify, redirect
from flask_cors import CORS
import requests
import jwt
import os
from functools import wraps
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# Configuration
SERVICES = {
    'tts': os.getenv('TTS_SERVICE_URL', 'http://tts-service:80'),
    'stt': os.getenv('STT_SERVICE_URL', 'http://stt-service:80'),
    'chat': os.getenv('CHAT_SERVICE_URL', 'http://chat-service:80'),
    'documents': os.getenv('DOCUMENT_SERVICE_URL', 'http://document-service:80'),
    'quiz': os.getenv('QUIZ_SERVICE_URL', 'http://quiz-service:80')
}

JWT_SECRET = os.getenv('JWT_SECRET', 'your-secret-key-change-in-production')
JWT_ALGORITHM = 'HS256'

def generate_token(user_id):
    """Generate JWT token for user"""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=24),
        'iat': datetime.utcnow()
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def verify_token(token):
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def require_auth(f):
    """Decorator to require authentication"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(' ')[1]  # Bearer <token>
            except IndexError:
                return jsonify({'error': 'Invalid token format'}), 401
        
        if not token:
            return jsonify({'error': 'Token is missing'}), 401
        
        payload = verify_token(token)
        if not payload:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        request.user_id = payload['user_id']
        return f(*args, **kwargs)
    return decorated

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'api-gateway'}), 200

@app.route('/api/auth/login', methods=['POST'])
def login():
    """Authentication endpoint (simplified - should integrate with user service)"""
    data = request.get_json()
    user_id = data.get('user_id')  # In production, verify credentials
    
    if not user_id:
        return jsonify({'error': 'Invalid credentials'}), 401
    
    token = generate_token(user_id)
    return jsonify({'token': token, 'user_id': user_id}), 200

@app.route('/api/tts/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def route_tts(path):
    """Route requests to TTS service"""
    return proxy_request('tts', path)

@app.route('/api/stt/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def route_stt(path):
    """Route requests to STT service"""
    return proxy_request('stt', path)

@app.route('/api/chat/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def route_chat(path):
    """Route requests to Chat service"""
    return proxy_request('chat', path)

@app.route('/api/documents/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def route_documents(path):
    """Route requests to Document service"""
    return proxy_request('documents', path)

@app.route('/api/quiz/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
@require_auth
def route_quiz(path):
    """Route requests to Quiz service"""
    return proxy_request('quiz', path)

def proxy_request(service_name, path):
    """Proxy request to appropriate service"""
    service_url = SERVICES.get(service_name)
    if not service_url:
        return jsonify({'error': 'Service not found'}), 404
    
    url = f"{service_url}/api/{service_name}/{path}"
    if request.query_string:
        url += f"?{request.query_string.decode()}"
    
    try:
        # Forward request with headers
        headers = {
            'Content-Type': request.content_type,
            'X-User-ID': getattr(request, 'user_id', 'anonymous')
        }
        
        response = requests.request(
            method=request.method,
            url=url,
            headers=headers,
            data=request.get_data(),
            params=request.args,
            timeout=30
        )
        
        return response.content, response.status_code, response.headers.items()
    except requests.exceptions.RequestException as e:
        return jsonify({'error': f'Service unavailable: {str(e)}'}), 503

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)

