from flask import Blueprint

bp = Blueprint(name="visitor", import_name=__name__, url_prefix="/visitor")

from . import routes
