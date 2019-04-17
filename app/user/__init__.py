from flask import Blueprint

bp = Blueprint(name="user", import_name=__name__, url_prefix="/user")

from . import routes
