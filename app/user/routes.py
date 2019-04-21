from flask import render_template, jsonify, request, flash
from flask_login import login_required, current_user, fresh_login_required

from . import bp
from .forms import ManageProfileForm
from app.models import Employee, Transit
from app.util import validate_date, db_procedure, DatabaseError, process_phone


@bp.route("/")
@bp.route("/home")
@login_required
def home():
    return render_template("home-user.html", title="Home")


@bp.route("/take_transit")
@login_required
def take_transit():
    result, error = db_procedure("get_all_sites", ())
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
    site_names = [row[0] for row in result]
    return render_template("user-take-transit.html", title="Take Transit", sites=site_names)


@bp.route("/take_transit/_get_table_data")
@login_required
def take_transit_get_table_data():
    site_name = request.args.get("site_name", type=str)
    transits = Transit.get_by_site_name(site_name)
    return jsonify({"data": [transit.__dict__ for transit in transits]})


@bp.route("/take_transit/_send_data", methods=["POST"])
@login_required
def take_transit_send_data():
    date = request.json["date"]
    if not validate_date(date):
        return jsonify({"result": "Date format incorrect."})
    route = request.json["route"]
    transport_type = Transit.Type.coerce(request.json["transport_type"])
    args = (current_user.username, route, str(transport_type), date)
    result, error = db_procedure("take_transit", args)
    if error:
        raise DatabaseError("An error occurred when logging transit: " + error)
    return jsonify({"result": "Successfully logged transit."})


@bp.route("/transit_history")
@login_required
def transit_history():
    result, error = db_procedure("get_all_sites", ())
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
    site_names = [row[0] for row in result]
    return render_template("user-transit-history.html", title="Take Transit", sites=site_names)


@bp.route("/transit_history/_get_table_data")
@login_required
def transit_history_get_table_data():
    site_name = request.args.get("site_name", type=str)
    args = (current_user.username, site_name, "", None, None)
    result, error = db_procedure("filter_transit_history", args)
    if error:
        raise DatabaseError("An error occurred when querying user transit history: " + error)
    return jsonify({"data": [{
        "route": row[0],
        "transport_type": row[1],
        "price": row[2],
        "date": row[3],
    } for row in result]})


@bp.route("/manage_profile", methods=["GET", "POST"])
@fresh_login_required
def manage_profile():
    form = ManageProfileForm()
    if form.validate_on_submit():
        if form.submit.data:
            user = current_user  # type: Employee
            user.first_name = form.first_name.data
            user.last_name = form.last_name.data
            user.phone = process_phone(form.phone.data)
            user.is_visitor = form.visitor.data
            user.update()
            for email_form in form.emails.entries:
                user.add_email(email_form.email.data)
            flash("Your account has been updated!", category="success")
        elif form.add.data:
            form.add_email()
        else:
            form.delete_email()
    else:
        form.populate(current_user)
    return render_template("user-manage-profile.html", title="Manage Account", form=form)
