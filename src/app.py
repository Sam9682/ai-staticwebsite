"""Main Flask application"""
from flask import Flask, render_template, jsonify
from flask_cors import CORS
from .config import SECRET_KEY, USER_ID, USER_NAME, USER_EMAIL, DESCRIPTION, PORT

def create_app():
    """Application factory"""
    app = Flask(__name__, template_folder='../templates', static_folder='../static')
    app.secret_key = SECRET_KEY
    
    # Configure CORS
    CORS(app, supports_credentials=True)
    
    @app.route('/')
    def index():
        """Main page displaying user information"""
        user_info = {
            'id': USER_ID,
            'name': USER_NAME,
            'email': USER_EMAIL,
            'description': DESCRIPTION,
            'port': PORT
        }
        return render_template('index.html', user=user_info)
    
    @app.route('/health')
    def health():
        """Health check endpoint"""
        return jsonify({'status': 'healthy', 'user_id': USER_ID})
    
    @app.route('/api/info')
    def api_info():
        """API endpoint returning user information"""
        return jsonify({
            'user_id': USER_ID,
            'name': USER_NAME,
            'email': USER_EMAIL,
            'description': DESCRIPTION,
            'port': PORT
        })
    
    return app