from flask import render_template, request, jsonify, redirect, url_for, flash
from flask.json import dumps
from flask_login import login_required, current_user
from . import bp
from .forms import EditSiteForm
from app.util import db_procedure, DatabaseError
from app.models import User


@bp.route("/home")
@login_required
def home():
    return render_template("home-administrator.html", title="Home")


@bp.route("/manage_user")
@login_required
def manage_user():
    result, error = db_procedure("filter_user", ("", "", ""))
    if error:
        raise DatabaseError("An error occurred when getting all users: " + error)
    users = []
    for row in result:
        users.append({"username": row[0], "email_count": row[1], "user_type": row[2], "status": row[3]})
    return render_template("administrator-manage-user.html", title="Manage Users", users=dumps(users))


@bp.route("/manage_user/_send_data", methods=["POST"])
@login_required
def manage_user_send_data():
    username = request.args.get("username")
    status = request.args.get("status", type=User.Status.coerce)
    if current_user.status == status:
        return jsonify({"result": False, "message": "The user status has not been changed."})
    if status == User.Status.PENDING.value:
        return jsonify({"result": False, "message": "You can not change a user's status to PENDING!"})
    if current_user.status == User.Status.APPROVED.value:
        return jsonify({"result": False, "message": "You can not change an approved user's status!"})
    args = (username, status)
    result, error = db_procedure("manage_user", args)
    if error:
        return jsonify({"result": False, "message": "An internal error prevented the user's status from being updated: " + error})
    current_user.status = User.Status[status]
    return jsonify({"result": True, "message": "Successfully updated the user's status."})


@bp.route("/manage_site")
@login_required
def manage_site():
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "manager_name": row[1],
            "open_every_date": row[2]
        })
    return render_template("administrator-manage-site.html", title="Manage Sites", sites=dumps(sites))


@bp.route("/manage_site/_send_data", methods=["DELETE"])
@login_required
def manage_site_send_data():
    site_name = request.args.get("site_name", type=str)
    result, error = db_procedure("delete_site", (site_name,))
    if error:
        return jsonify({"result": False, "message": "An error occurred preventing deletion of the site: " + error})
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
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
    site_name = request.args.get("site_name", type=str)
    form = EditSiteForm()
    if form.validate_on_submit():
        args = (form.name.data, form.zip_code.data, form.address.data, form.manager.data, int(form.open_everyday.data))
        result, error = db_procedure("edit_site", args)
        if error:
            raise DatabaseError("An error occurred when editing site: " + error)
        flash(message="Site updated!", category="success")
        return redirect(url_for(".manage_site"))
    args = (site_name,)
    result, error = db_procedure("query_site_by_site_name", args)
    if error:
        raise DatabaseError("An error occurred when querying site: " + error)
    zip_code, address, open_everyday, manager = result[0]
    form.name.data = site_name
    form.zip_code.data = zip_code
    form.address.data = address
    form.manager.choices = [(manager, manager) for manager in EditSiteForm.get_free_managers()] + [(manager, manager)]
    form.manager.data = manager
    form.open_everyday.data = open_everyday
    return render_template("administrator-edit-site.html", title="Edit Site", form=form)


@bp.route("/create_site")
@login_required
def create_site():
    form = EditSiteForm()
    if form.validate_on_submit():
        args = (form.name.data, form.zip_code.data, form.address.data, form.manager.data, int(form.open_everyday.data))
        result, error = db_procedure("create_site", args)
        if error:
            raise DatabaseError("An error occurred when creating site: " + error)
        flash(message="Site created!", category="success")
        return redirect(url_for(".manage_site"))
    form.manager.choices = [(manager, manager) for manager in EditSiteForm.get_free_managers()]
    return render_template("administrator-edit-site.html", title="Create Site", form=form)


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
