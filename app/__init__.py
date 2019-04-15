from flask import Flask
from flask_mysqldb import MySQL
from flask_bcrypt import Bcrypt
from flask_login import LoginManager

from app import configs

# Instantiate extensions
db = MySQL()
bcrypt = Bcrypt()
login_manager = LoginManager()


# Login Manager setup
login_manager.login_view = "login"  # set view function for login (when login_required is triggered)
login_manager.login_message_category = "info"  # set login message style


def create_app(config_class="Config"):
    """
    Factory method to create an app instance.

    :param config_class: the name of the Config class to import
    :type config_class: configs.Config
    :return: a Flask app instance
    :rtype: Flask
    """
    app = Flask(__name__)

    # Import the specified Config class from configs.py
    app.config.from_object(configs.__name__ + "." + config_class)

    # Initialize extensions
    db.init_app(app)
    bcrypt.init_app(app)
    login_manager.init_app(app)

    return app
