from flask import render_template, json, request, flash, redirect, url_for, jsonify
from flask_login import login_required, current_user
from . import bp
from .forms import EventDetailForm
from app.util import db_procedure, DatabaseError, validate_date


@bp.route("/explore_event")
@login_required
def explore_event():
    args = (current_user.username,) + ("",) * 3 + ("0000-00-00",) * 2 + (0,) * 4 + (1,) * 2
    result, error = db_procedure("filter_event_vis", args)
    if error:
        raise DatabaseError("An error occurred when getting all events for a visitor:" + error)
    events = []
    for row in result:
        events.append({
            "event_name": row[0],
            "site_name": row[1],
            "ticket_price": row[2],
            "ticket_remaining": row[3],
            "total_visits": row[4],
            "my_visits": row[5],
            "start_date": row[6],
            "end_date": row[7],
        })
    return render_template("visitor-explore-event.html", title="Explore Event", events=json.dumps(events))


@bp.route("/event_detail")
@login_required
def event_detail():
    form = EventDetailForm()
    if form.validate_on_submit():
        date = form.visit_date.data
        args = (form.site.data, form.event.data, form.start_date.data, current_user.username, date)
        result, error = db_procedure("log_event", args)
        if error:
            raise DatabaseError("An error occurred when logging event for visitor: " + error)
        flash(message="You have successfully logged your visit!", category="success")
        return redirect(url_for(".explore_event"))
    site_name = request.args.get("site_name", type=str)
    event_name = request.args.get("event_name", type=str)
    start_date = request.args.get("start_date", type=str)
    if not validate_date(start_date):
        raise ValueError("Start date format incorrect!")
    result, error = db_procedure("query_event_by_pk", (site_name, event_name, start_date))
    if error:
        raise DatabaseError("An error occurred when getting event detail for visitor: " + error)
    end_date, _, _, description, _, price = result[0]
    args = (current_user.username, event_name, "", site_name, start_date, "0000-00-00") + (0,) * 4 + (1,) * 2
    result, error = db_procedure("filter_event_vis", args)
    if error:
        raise DatabaseError("An error occurred when querying event for visitor:" + error)
    tickets_remaining = result[3]
    form.event.data = event_name
    form.site.data = site_name
    form.start_date.data = start_date
    form.end_date.data = end_date
    form.ticket_price.data = price
    form.tickets_remaining.data = tickets_remaining
    form.description.data = description
    return render_template("visitor-event-detail.html", title="Event Detail", form=form)


@bp.route("/explore_site")
@login_required
def explore_site():
    args = (current_user.username, "", 0,) + ("0000-00-00",) * 2 + (0,) * 4 + (1,)
    result, error = db_procedure("filter_site_vis", args)
    if error:
        raise DatabaseError("An error occurred when getting all sites for visitor: " + error)
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "event_count": row[1],
            "total_visits": row[2],
            "my_visits": row[3],
            "date": row[4],
            "open_everyday": row[5],
        })
    return render_template("visitor-explore-site.html", title="Explore Site", sites=json.dumps(sites))


@bp.route("/transit_detail")
@login_required
def transit_detail():
    site_name = request.args.get("site_name", type=str)
    result, error = db_procedure("query_transit_by_site", (site_name,))
    if error:
        raise DatabaseError("An error occurred when getting all transits for site: " + error)
    transits = []
    for row in result:
        transits.append({
            "route": row[0],
            "transport_type": row[1],
            "price": row[2],
        })
    return render_template("visitor-transit-detail.html", title="Transit Detail", transits=json.dumps(transits))


@bp.route("/transit_detail/_send_data", methods=["POST"])
@login_required
def transit_detail_send_data():
    route = request.json["route"]
    transport_type = request.json["transport_type"]
    date = request.json["date"]
    result, error = db_procedure("take_transit", (current_user.username, route, transport_type, date))
    if error:
        raise DatabaseError("An error occurred when logging transit for visitor: " + error)
    return jsonify({"result": True, "message": "Successfully logged transit."})


@bp.route("/site_detail")
@login_required
def site_detail():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/visit_history")
@login_required
def visit_history():
    return "Not implemented yet!"  # TODO: implement this method
