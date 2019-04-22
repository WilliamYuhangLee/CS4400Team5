from flask import render_template, request, jsonify, json
from flask_login import login_required, current_user
from . import bp
from app.util import validate_date, db_procedure, DatabaseError


@bp.route("/home")
@login_required
def home():
    return render_template("home-manager.html", title="Home")


@bp.route("/manage_event")
@login_required
def manage_event():
    args = (current_user.username, "", "",) + ("0000-00-00",) * 2 + (0,) * 6
    result, error = db_procedure("filter_event_adm", args)
    if error:
        raise DatabaseError("An error occurred when querying events for manager: " + error)
    events = []
    for row in result:
        events.append({
            "name": row[0],
            "staff_count": row[1],
            "duration": row[2],
            "total_visits": row[3],
            "total_revenue": row[4],
            "description": row[5],
            "start_date": row[6],
            "end_date": row[7],
        })
    return render_template("manager-manage-event.html", title="Manage Event", events=json.dumps(events))


@bp.route("/manage_event/_send_data", methods=["POST", "DELETE"])
@login_required
def manage_event_send_data():
    site_name = request.json["site_name"]
    event_name = request.json["event_name"]
    start_date = request.json["start_date"]
    result, error = db_procedure("delete_event", (site_name, event_name, start_date))
    if error:
        raise DatabaseError("An error occurred when deleting event: " + error)
    return jsonify({"result": True, "message": "Successfully deleted event."})


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


@bp.route("/site_report")
@login_required
def site_report():
    return render_template("manager-site-report.html")


@bp.route("/site_report/_get_data")
@login_required
def site_report_get_data():
    start_date = request.args.get("start_date", type=str)
    if not validate_date(start_date):
        return jsonify({"result": False, "message": "Start date format incorrect."})
    end_date = request.args.get("end_date", type=str)
    if not validate_date(end_date):
        return jsonify({"result": False, "message": "End date format incorrect."})
    result, error = db_procedure("query_employee_sitename", (current_user.username,))
    if error:
        raise DatabaseError("An error occurred when getting manager's site name: " + error)
    site_name = result[0][0]
    result, error = db_procedure("filter_daily_site", (site_name, start_date, end_date, 0, 0, 0, 0, 0, 0, 0, 0))
    if error:
        raise DatabaseError("An error occurred when getting manager's site reports: " + error)
    reports = []
    for row in result:
        reports.append({
            "date": row[0],
            "event_count": row[1],
            "staff_count": row[2],
            "total_visit": row[3],
            "total_revenue": row[4],
        })
    return jsonify({"result": True, "data": reports})


@bp.route("/daily_detail")
@login_required
def daily_detail():
    date = request.args.get("date", type=str)
    if not validate_date(date):
        raise ValueError("Date format incorrect!")
    result, error = db_procedure("query_employee_sitename", (current_user.username,))
    if error:
        raise DatabaseError("An error occurred when getting manager's site name: " + error)
    site_name = result[0][0]
    result, error = db_procedure("filter_daily_event", (site_name, date))
    if error:
        raise DatabaseError("An error occurred when getting site's daily detail: " + error)
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
            raise DatabaseError("An error occurred when querying staff for an event: " + error)
        event["staff_names"] = []
        for staff in result:
            event["staff_names"].append(staff[1] + staff[2])
    return render_template("manager-daily-detail.html", title="Daily Detail", detail=detail)
