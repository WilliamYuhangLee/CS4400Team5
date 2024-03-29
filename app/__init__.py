import os
from flask import Flask
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
from flask_login import LoginManager

from app import configs

# Instantiate extensions
db = MySQL()
bcrypt = Bcrypt()
login_manager = LoginManager()


def create_app():
    """
    Factory method to create an app instance.

    :return: a Flask app instance
    :rtype: Flask
    """
    app = Flask(__name__)

    # Detect Config class from environment and import the specified Config class from configs.py
    config_class = os.getenv("FLASK_CONFIG", "Config")
    app.config.from_object(configs.__name__ + "." + config_class)

    # Initialize extensions
    db.init_app(app)
    bcrypt.init_app(app)
    login_manager.init_app(app)

    # Register Blueprints
    from .main import bp
    app.register_blueprint(bp)
    from .user import bp
    app.register_blueprint(bp)
    from .visitor import bp
    app.register_blueprint(bp)
    from .administrator import bp
    app.register_blueprint(bp)
    from .manager import bp
    app.register_blueprint(bp)
    from .staff import bp
    app.register_blueprint(bp)

    # Login Manager setup
    login_manager.login_view = "main.login"  # set view function for login (when login_required is triggered)
    login_manager.login_message = "Please log in to view this page."
    login_manager.login_message_category = "warning"  # set login message style
    from models import User
    login_manager.user_callback = User.get_by_username

    return app
