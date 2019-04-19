from flask import render_template
from flask_login import login_required, current_user
from . import bp


@bp.route("/home")
@login_required
def home():
    return render_template("home-administrator.html", title="Home")


@bp.route("/manage-user")
@login_required
def manage_user():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage-site")
@login_required
def manage_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/edit-site")
@login_required
def edit_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/create-site")
@login_required
def create_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage-transit")
@login_required
def manage_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/edit-transit")
@login_required
def edit_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/create-transit")
@login_required
def create_transit():
    return "Not implemented yet!"  # TODO: implement this method
