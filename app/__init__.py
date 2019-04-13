from flask import Flask
from flask_mysqldb import MySQL

from app import configs

# Instantiate extensions
db = MySQL()


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

    return app
