from flask import render_template
from flask_login import login_required, current_user
from . import bp


@bp.route("/home")
@login_required
def home():
    return render_template("home-staff.html", title="Home")


@bp.route("/view-schedule")
@login_required
def view_schedule():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/event-detail")
@login_required
def event_detail():
    return "Not implemented yet!"  # TODO: implement this method
