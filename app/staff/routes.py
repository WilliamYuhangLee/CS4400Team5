from flask import render_template, request
from flask.json import dumps
from flask_login import login_required, current_user
from . import bp
from .forms import EventDetailForm
from app.util import db_procedure, DatabaseError


@bp.route("/")
@bp.route("/home")
@login_required
def home():
    return render_template("home-staff.html", title="Home")


@bp.route("/view_schedule")
@login_required
def view_schedule():
    username = current_user.username
    result, error = db_procedure("filter_schedule", (username, "", "", None, None))
    if error:
        raise DatabaseError(error, "getting staff's events")
    events = []
    for row in result:
        events.append({
            "event_name": row[0],
            "site_name": row[1],
            "start_date": row[2],
            "end_date": row[3],
            "staff_count": row[4],
            "description": row[5],
        })
    return render_template("staff-view-schedule.html", title="View Schedule", events=dumps(events))


@bp.route("/event_detail")
@login_required
def event_detail():
    event_name = request.args.get("event_name")
    site_name = request.args.get("site_name")
    start_date = request.args.get("start_date")
    result, error = db_procedure("query_event_by_pk", (site_name, event_name, start_date))
    if error:
        raise DatabaseError(error, "getting event detail")
    end_date, min_staff_req, capacity, description, duration, price = result[0]
    result, error = db_procedure("query_staff_by_event", (site_name, event_name, start_date))
    if error:
        raise DatabaseError(error, "getting event's assigned staffs")
    staffs = [row[1] + row[2] for row in result]
    form = EventDetailForm()
    form.event.data = event_name
    form.site.data = site_name
    form.start_date.data = start_date
    form.end_date.data = end_date
    form.duration_days.data = duration
    form.capacity.data = capacity
    form.price.data = price
    form.description.data = description
    for staff in staffs:
        form.staffs_assigned.append_entry(staff)
    return render_template("staff-event-detail.html", title="Event Detail", form=form)
