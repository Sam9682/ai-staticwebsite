"""Main Flask application"""
from flask import Flask, render_template, jsonify, request
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
    
    @app.route('/admin')
    def admin():
        """Admin panel for website management"""
        return render_template('admin.html', user={'name': USER_NAME})
    
    @app.route('/admin/upload', methods=['POST'])
    def upload_website():
        """Handle website zip upload"""
        import os
        import zipfile
        from datetime import datetime
        from flask import request, flash, redirect, url_for
        
        if 'website' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        
        file = request.files['website']
        if file.filename == '' or not file.filename.endswith('.zip'):
            return jsonify({'error': 'Please upload a zip file'}), 400
        
        # Create timestamped directory
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        website_dir = f'/var/www/web_site_source_{timestamp}'
        os.makedirs(website_dir, exist_ok=True)
        
        # Extract zip file
        zip_path = f'/tmp/website_{timestamp}.zip'
        file.save(zip_path)
        
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(website_dir)
        
        # Update symlink to point to new version
        html_link = '/var/www/html'
        if os.path.islink(html_link):
            os.unlink(html_link)
        elif os.path.exists(html_link):
            os.rename(html_link, f'/var/www/html_backup_{timestamp}')
        
        os.symlink(website_dir, html_link)
        os.remove(zip_path)
        
        return jsonify({'success': True, 'version': timestamp})
    
    return app