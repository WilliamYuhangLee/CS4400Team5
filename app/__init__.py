from flask import Flask

from app import configs

def create_app(config="Config"):
    app = Flask(__name__)
    app.config.from_object(configs.__name__ + "." + config)

    return app
