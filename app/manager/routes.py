from flask import render_template
from flask_login import login_required, current_user
from . import bp


@bp.route("/home")
@login_required
def home():
    return render_template("home-manager.html", title="Home")


@bp.route("/manage-event")
@login_required
def manage_event():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/edit-event")
@login_required
def edit_event():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/create-event")
@login_required
def create_event():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage-staff")
@login_required
def manage_staff():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/site-report")
@login_required
def site_report():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/daily-detail")
@login_required
def daily_detail():
    return "Not implemented yet!"  # TODO: implement this method
