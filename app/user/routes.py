from flask_login import login_required

from . import bp


@bp.route("/home")
@login_required
def home():
    pass  # TODO: implement homepage


@bp.route("/take-transit")
def take_transit():
    pass  # TODO: implement this method
