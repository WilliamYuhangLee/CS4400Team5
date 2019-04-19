from flask import render_template
from flask_login import login_required, current_user

from . import bp


@bp.route("/home")
@login_required
def home():
    return render_template("home-user.html", title="Home")


@bp.route("/take-transit")
@login_required
def take_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/transit-history")
@login_required
def transit_history():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage-profile")
@login_required
def manage_profile():
    return "Not implemented yet!"  # TODO: implement this method
