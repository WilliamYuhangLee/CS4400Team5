from flask import Blueprint

bp = Blueprint(name="administrator", import_name=__name__, url_prefix="/administrator")

from . import routes
