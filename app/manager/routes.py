from flask import render_template, request, jsonify, json, session, flash, redirect, url_for
from flask_login import login_required, current_user
from . import bp
from .forms import EditEventForm, CreateEventForm
from app.util import validate_date, db_procedure, DatabaseError, role_required


@bp.route("/")
@bp.route("/home")
@login_required
def home():
    result, error = db_procedure("query_employee_sitename", (current_user.username,))
    if error:
        raise DatabaseError(error, "query_employee_sitename")
    session[current_user.username] = {}
    session[current_user.username]["site_name"] = result[0][0]
    return render_template("home-manager.html", title="Home")


@bp.route("/manage_event")
@login_required
def manage_event():
    args = (current_user.username, "", "",) + (0,) * 6
    result, error = db_procedure("filter_event_adm", args)
    if error:
        raise DatabaseError(error, "querying events for manager")
    events = []
    for row in result:
        events.append({
            "name": row[0],
            "staff_count": row[1],
            "duration": row[2],
            "total_visits": int(row[3]),
            "total_revenue": float(row[4]),
            "description": row[5],
            "start_date": row[6],
            "end_date": row[7],
        })
    return render_template("manager-manage-event.html", title="Manage Event", events=json.dumps(events))


@bp.route("/manage_event/_send_data", methods=["POST", "DELETE"])
@login_required
def manage_event_send_data():
    site_name = session[current_user.username]["site_name"]
    event_name = request.json["event_name"]
    start_date = request.json["start_date"]
    result, error = db_procedure("delete_event", (site_name, event_name, start_date))
    if error:
        raise DatabaseError(error, "deleting event")
    return jsonify({"result": True, "message": "Successfully deleted event."})


@bp.route("/edit_event")
@login_required
def edit_event():
    form = EditEventForm()
    site_name = session[current_user.username]["site_name"]
    if form.validate_on_submit():
        new_staffs = form.staff_assigned.data
        old_staffs = session[current_user.username]["old_staffs"]
        all_staffs = session[current_user.username]["all_staffs"]
        for staff in new_staffs:
            if staff not in old_staffs:
                result, error = db_procedure("assign_staff", (site_name, form.name.data, form.start_date.data, all_staffs[staff]))
                if error:
                    raise DatabaseError(error, "assigning staff")
        for staff in old_staffs:
            if staff not in new_staffs:
                result, error = db_procedure("remove_staff", (site_name, form.name.data, form.start_date.data, all_staffs[staff]))
                if error:
                    raise DatabaseError(error, "removing staff")
        result, error = db_procedure("edit_event",
                                    (site_name, form.name.data, form.start_date.data, form.description.data))
        if error:
            raise DatabaseError(error, "editing description for event")
        flash(message="You have successfully edited the event!", category="success")
        return redirect(url_for(".manage_event"))
    event_name = request.args.get("event_name")
    start_date = request.args.get("start_date")
    result, error = db_procedure("query_event_by_pk", (site_name, event_name, start_date))
    if error:
        raise DatabaseError(error, "getting event detail")
    end_date, min_staff_req, capacity, description, duration, price = result[0]
    result, error = db_procedure("query_staff_by_event", (site_name, event_name, start_date))
    if error:
        raise DatabaseError(error, "querying staff for an event")
    old_staffs = {}
    for staff in result:
        old_staffs[staff[1] + staff[2]] = staff[0]
    session[current_user.username]["old_staffs"] = old_staffs
    session[current_user.username]["site_name"] = site_name
    all_staffs = old_staffs.copy()
    result, error = db_procedure("get_free_staff", (start_date, end_date))
    if error:
        raise DatabaseError(error, "get_free_staff")
    for staff in result:
        all_staffs[staff[1] + staff[2]] = staff[0]
    session[current_user.username]["all_staffs"] = all_staffs
    form.staff_assigned.choices = [(name, name) for name in all_staffs.keys()]
    form.name.data = event_name
    form.price.data = price
    form.start_date.data = start_date
    form.end_date.data = end_date
    form.minimum_staff_required.data = min_staff_req
    form.capacity.data = capacity
    form.staff_assigned.data = old_staffs.keys()
    form.description.data = description
    result, error = db_procedure("query_event_day_by_day", (site_name, event_name, start_date))
    if error:
        DatabaseError(error, "getting events for site")
    days = []
    for row in result:
        days.append({
            "event_name": event_name,
            "site_name": site_name,
            "start_date": row[0],
            "daily_visit": row[1],
            "daily_revenue": row[2],
        })
    return render_template("manager-edit-event.html", title="Edit Event", form=form, days=json.dumps(days))


@bp.route("/create_event")
@login_required
def create_event():
    form = CreateEventForm()
    site_name = session[current_user.username]["site_name"]
    if form.validate_on_submit():
        args = (site_name, form.name.data, form.start_date.data, form.end_date.data,
                form.minimum_staff_required.data, form.price.data, form.capacity.data, form.description.data)
        result, error = db_procedure("create_event", args)
        if error:
            raise DatabaseError(error, "create_event")
        free_staffs = session[current_user.username]["free_staffs"]
        for staff in form.assign_staff.data:
            result, error = db_procedure("assign_staff", (site_name, form.name.data, form.start_date.data, free_staffs[staff]))
            if error:
                raise DatabaseError(error, "assign_staff")
        flash(message="Event created!", category="success")
        return redirect(url_for(".manage_event"))
    if form.start_date.data and form.end_date.data:
        args = (form.start_date.data, form.end_date.data)
    else:
        args = ("1000-01-01", "9999-12-31")
    result, error = db_procedure("get_free_staff", args)
    if error:
        raise DatabaseError(error, "get_free_staff")
    free_staffs = {}
    for staff in result:
        free_staffs[staff[1] + staff[2]] = staff[0]
    form.assign_staff.choices = free_staffs.keys()
    session[current_user.username]["free_staffs"] = free_staffs
    form.site_name.data = site_name
    return render_template("manager-create-event.html", title="Create Event", form=form)


@bp.route("/manage_staff")
@login_required
def manage_staff():
    result, error = db_procedure("filter_staff", ("",) * 3)
    if error:
        raise DatabaseError(error, "filter_staff")
    staffs = []
    for row in result:
        staffs.append({
            "first_name": row[0],
            "last_name": row[1],
            "num_of_event_shifts": row[2],
            "site_name": row[3],
            "start_date": row[4],
            "end_date": row[5],
        })
    return render_template("manager-manage-staff.html", title="Manage Staff", staffs=json.dumps(staffs))


@bp.route("/site_report")
@login_required
def site_report():
    site_name = session[current_user.username]["site_name"]
    result, error = db_procedure("filter_daily_site", (site_name,) + (0,) * 8)
    if error:
        raise DatabaseError(error, "filter_daily_site")
    reports = []
    for row in result:
        reports.append({
            "date": row[0],
            "event_count": int(row[1]),
            "staff_count": int(row[2]),
            "total_visit": int(row[3]),
            "total_revenue": float(row[4]),
        })
    return render_template("manager-site-report.html", title="Manage Site", reports=json.dumps(reports))


@bp.route("/daily_detail")
@login_required
def daily_detail():
    date = request.args.get("date", type=str)
    if not validate_date(date):
        raise ValueError("Date format incorrect!")
    result, error = db_procedure("query_employee_sitename", (current_user.username,))
    if error:
        raise DatabaseError(error, "getting manager's site name")
    site_name = result[0][0]
    result, error = db_procedure("filter_daily_event", (site_name, date))
    if error:
        raise DatabaseError(error, "getting site's daily detail")
    detail = []
    for row in result:
        detail.append({
            "event_name": row[0],
            "site_name": row[1],
            "start_date": row[2],
            "visits": row[3],
            "revenue": row[4],
        })
    for event in detail:
        result, error = db_procedure("query_staff_by_event", (event["site_name"], event["event_name"], event["start_date"]))
        if error:
            raise DatabaseError(error, "querying staff for an event")
        event["staff_names"] = []
        for staff in result:
            event["staff_names"].append(staff[1] + staff[2])
    return render_template("manager-daily-detail.html", title="Daily Detail", detail=detail)
