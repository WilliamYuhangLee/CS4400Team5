from flask import render_template, request, jsonify, redirect, url_for, flash, session
from flask.json import dumps
from flask_login import login_required, current_user
from . import bp
from .forms import EditSiteForm, EditTransitForm, CreateTransitForm
from app.util import db_procedure, DatabaseError
from app.models import User, Transit, Site, Employee


@bp.route("/")
@bp.route("/home")
@login_required
def home():
    session[current_user.username] = {}
    return render_template("home-administrator.html", title="Home")


@bp.route("/manage_user")
@login_required
def manage_user():
    result, error = db_procedure("filter_user", ("", "", ""))
    if error:
        raise DatabaseError(error, "getting all users")
    users = []
    for row in result:
        users.append({"username": row[0], "user_type": row[1], "status": row[2], "email_count": row[3]})
    return render_template("administrator-manage-user.html", title="Manage Users", users=dumps(users))


@bp.route("/manage_user/_send_data", methods=["POST"])
@login_required
def manage_user_send_data():
    username = request.json["username"]
    status = User.Status.coerce(request.json["status"])
    result, error = db_procedure("query_user_by_username", (username,))
    if error:
        return jsonify(
            {"result": False, "message": "An internal error stopped fetching of the user's status: " + error})
    current_status = User.Status.coerce(result[0][4])
    if current_status == status:
        return jsonify({"result": False, "message": "The user status has not been changed."})
    if status == User.Status.PENDING.value:
        return jsonify({"result": False, "message": "You can not change a user's status to PENDING!"})
    if current_status == User.Status.APPROVED.value:
        return jsonify({"result": False, "message": "You can not change an approved user's status!"})
    args = (username, status)
    result, error = db_procedure("manage_user", args)
    if error:
        return jsonify({"result": False, "message": "An internal error prevented the user's status from being updated: " + error})
    return jsonify({"result": True, "message": "Successfully updated the user's status."})


@bp.route("/manage_site")
@login_required
def manage_site():
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError(error, "getting all sites")
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "manager_name": row[1],
            "open_every_day": row[2]
        })
    return render_template("administrator-manage-site.html", title="Manage Sites", sites=dumps(sites))


@bp.route("/manage_site/_send_data", methods=["DELETE"])
@login_required
def manage_site_send_data():
    site_name = request.json["site_name"]
    result, error = db_procedure("delete_site", (site_name,))
    if error:
        return jsonify({"result": False, "message": "An error occurred preventing deletion of the site: " + error})
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError(error, "getting all sites")
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "manager_name": row[1],
            "open_every_date": row[2]
        })
    return jsonify({"result": True, "message": "Successfully deleted site.", "sites": sites})


@bp.route("/edit_site", methods=["GET", "POST"])
@login_required
def edit_site():
    form = EditSiteForm()
    form.manager.choices = [(manager, manager) for manager in Employee.get_free_managers()]
    if form.old_manager.data:
        form.manager.choices += [(form.old_manager.data, form.old_manager.data)]
    if form.validate_on_submit():
        args = (form.name.data, form.zip_code.data, form.address.data, form.manager.data, int(form.open_everyday.data))
        result, error = db_procedure("edit_site", args)
        if error:
            raise DatabaseError(error, "editing site")
        flash(message="Site updated!", category="success")
        return redirect(url_for(".manage_site"))
    site_name = request.args.get("site_name", type=str)
    args = (site_name,)
    result, error = db_procedure("query_site_by_site_name", args)
    if error:
        raise DatabaseError(error, "querying site")
    zip_code, address, open_everyday, manager = result[0]
    form.name.data = site_name
    form.old_name = site_name
    form.old_manager = manager
    form.zip_code.data = zip_code
    form.address.data = address
    form.manager.data = manager
    form.open_everyday.data = open_everyday
    return render_template("administrator-edit-site.html", title="Edit Site", form=form)


@bp.route("/create_site", methods=["GET", "POST"])
@login_required
def create_site():
    form = EditSiteForm()
    form.manager.choices = [(manager, manager) for manager in Employee.get_free_managers()]
    if form.validate_on_submit():
        args = (form.name.data, form.zip_code.data, form.address.data, form.manager.data, int(form.open_everyday.data))
        result, error = db_procedure("create_site", args)
        if error:
            raise DatabaseError(error, "creating site")
        flash(message="Site created!", category="success")
        return redirect(url_for(".manage_site"))
    return render_template("administrator-edit-site.html", title="Create Site", form=form)


@bp.route("/manage_transit")
@login_required
def manage_transit():
    result, error = db_procedure("get_all_sites", ())
    if error:
        raise DatabaseError(error, "getting all sites")
    site_names = [row[0] for row in result]
    return render_template("administrator-manage-transit.html", title="Take Transit", sites=site_names)


@bp.route("/manage_transit/_get_table_data")
@login_required
def manage_transit_get_table_data():
    site_name = request.args.get("site_name", type=str)
    args = (site_name, "", "", 0, 0)
    result, error = db_procedure("filter_transit", args)
    if error:
        raise DatabaseError(error, "querying transits by site name")
    transits = []
    for row in result:
        transits.append({
            "route": row[0],
            "transport_type": row[1],
            "price": row[2],
            "num_of_connected_sites": row[3],
            "num_of_logged_transits": row[4],
        })
    return jsonify({"data": transits})


@bp.route("/manage_transit/_send_data", methods=["POST"])
@login_required
def manage_transit_send_data():
    route = request.json["route"]
    transport_type = Transit.Type.coerce(request.json["transport_type"])
    args = (route, transport_type)
    result, error = db_procedure("delete_transit", args)
    if error:
        raise DatabaseError(error, "deleting transit")
    return jsonify({"result": True, "message": "Successfully deleted transit."})


@bp.route("/edit_transit", methods=["GET", "POST"])
@login_required
def edit_transit():
    form = EditTransitForm()
    form.sites.choices = [(site[0], site[0]) for site in Site.get_all_sites()]
    if form.validate_on_submit():
        transport_type = form.transport_type.data
        old_route = form.old_route.data
        new_route = form.route.data
        price = form.price.data
        result, error = db_procedure("query_transit_by_pk", (old_route, transport_type))
        if error:
            raise DatabaseError(error, "fetching transit")
        old_sites = []
        for row in result:
            old_sites.append(row[1])
        result, error = db_procedure("edit_transit", (transport_type, old_route, new_route, price))
        if error:
            raise DatabaseError(error, "editing transit")
        new_sites = form.sites.data
        for site in new_sites:
            if site not in old_sites:
                result, error = db_procedure("connect_site", (transport_type, new_route, site))
                if error:
                    raise DatabaseError(error, "connecting site")
        for site in old_sites:
            if site not in new_sites:
                result, error = db_procedure("disconnect_site", (transport_type, new_route, site))
                if error:
                    raise DatabaseError(error, "disconnecting site")
        flash(message="Transit updated!", category="success")
        return redirect(url_for(".manage_transit"))
    route = request.args.get("route", type=str)
    transport_type = request.args.get("transport_type", type=Transit.Type.coerce)
    result, error = db_procedure("query_transit_by_pk", (route, transport_type))
    if error:
        raise DatabaseError(error, "fetching transit")
    price = result[0][0]
    new_sites = []
    for row in result:
        new_sites.append(row[1])
    form.route.data = route
    form.old_route.data = route
    form.transport_type.data = transport_type
    form.price.data = price
    form.sites.data = new_sites
    return render_template("administrator-edit-transit.html", title="Edit Transit", form=form)


@bp.route("/create_transit", methods=["GET", "POST"])
@login_required
def create_transit():
    form = CreateTransitForm()
    form.sites.choices = [(site[0], site[0]) for site in Site.get_all_sites()]
    if form.validate_on_submit():
        transport_type = form.transport_type.data
        route = form.route.data
        price = form.price.data
        result, error = db_procedure("create_transit", (transport_type, route, price))
        if error:
            raise DatabaseError(error, "creating transit")
        sites = form.sites.data
        for site in sites:
            result, error = db_procedure("connect_site", (transport_type, route, site))
            if error:
                raise DatabaseError(error, "connecting site")
        flash(message="Transit created!", category="success")
        return redirect(url_for(".manage_transit"))
    return render_template("administrator-edit-transit.html", title="Create Transit", form=form)