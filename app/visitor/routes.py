from flask_login import login_required
from . import bp


@bp.route("/explore-event")
@login_required
def explore_event():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/event-detail")
@login_required
def event_detail():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/explore-site")
@login_required
def explore_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/transit-detail")
@login_required
def transit_detail():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/site-detail")
@login_required
def site_detail():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/visit-history")
@login_required
def visit_history():
    return "Not implemented yet!"  # TODO: implement this method
